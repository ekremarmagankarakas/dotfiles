----------------------------------------------------------------------
-- AI assistant abstraction
--
-- Inline-suggestion and chat operations are routed through here instead of
-- calling copilot.lua/CopilotChat.nvim directly. Copilot is the static,
-- always-available fallback; anything else (CodeCompanion, avante.nvim, a
-- Claude-based chat plugin, ...) registers itself with M.register_provider
-- and implements is_active() to say when it should take over.
-- get_active_provider() checks registered providers in registration order
-- and falls back to Copilot if none claim it.
--
-- The keymaps that call into this (lua/config/ai_keymaps.lua) are always
-- loaded, independent of whether copilot.lua/CopilotChat.nvim are enabled
-- via profile -- so the Copilot provider's own functions below guard every
-- call into those plugins and notify instead of erroring if one isn't
-- loaded.
--
-- NOT part of this abstraction: the ghost-text accept/next/prev/dismiss
-- insert-mode keys (copilot.lua's own `opts.suggestion.keymap`) and
-- CopilotChat's chat-buffer-local accept/show/yank-diff keys (its own
-- `opts.mappings`). Those are each plugin's tightly-coupled internal UI --
-- a different provider would wire its own equivalent independently, same
-- as Diffview's conflict-resolution keymaps stayed plugin-local for VCS.
----------------------------------------------------------------------

local M = {}

local custom_providers = {}

local SCHEMA_GROUPS = { "suggest", "chat" }

----------------------------------------------------------------------
-- Guards: call into an optional module/command without erroring if it
-- isn't loaded (e.g. its owning plugin is disabled via profile).
----------------------------------------------------------------------

local function with_module(mod_name, fn)
	return function(...)
		local ok, mod = pcall(require, mod_name)
		if not ok then
			vim.notify(
				string.format("ai: %s is not loaded (plugin disabled?)", mod_name),
				vim.log.levels.WARN
			)
			return
		end
		return fn(mod, ...)
	end
end

-- `vim.fn.exists(":Cmd")` is true for lazy.nvim's placeholder too, so this
-- still lets the plugin lazy-load on first use -- it only fails closed when
-- the plugin was never going to load at all (disabled via profile).
local function with_command(cmd)
	local name = cmd:match("^%S+")
	return function()
		if vim.fn.exists(":" .. name) ~= 2 then
			vim.notify(
				string.format("ai: %s is not available (copilot.lua/CopilotChat.nvim disabled?)", name),
				vim.log.levels.WARN
			)
			return
		end
		vim.cmd(cmd)
	end
end

----------------------------------------------------------------------
-- Built-in Copilot provider (the fallback; always available, no is_active)
----------------------------------------------------------------------
local copilot_auto_trigger = false

local copilot_provider = {
	name = "copilot",

	suggest = {
		toggle = with_command("Copilot toggle"),
		enable = with_command("Copilot enable"),
		disable = with_command("Copilot disable"),
		toggle_auto_trigger = with_module("copilot.suggestion", function(suggestion)
			copilot_auto_trigger = not copilot_auto_trigger
			suggestion.toggle_auto_trigger()
			vim.notify("Copilot auto-trigger: " .. (copilot_auto_trigger and "ON" or "OFF"))
		end),
	},

	chat = {
		toggle = with_command("CopilotChatToggle"),
		-- Use the built-in #selection resource so this doesn't need its own
		-- selection API; same pattern as before, just routed through here.
		fix = with_module("CopilotChat", function(chat)
			chat.ask("#selection /Fix", { prompt = "Fix selection" })
		end),
		refactor = with_module("CopilotChat", function(chat)
			chat.ask("#selection /Optimize", { prompt = "Refactor selection" })
		end),
		explain = with_module("CopilotChat", function(chat)
			chat.ask("#selection /Explain", { prompt = "Explain selection" })
		end),
		tests = with_module("CopilotChat", function(chat)
			chat.ask("#selection /Tests", { prompt = "Generate tests for selection" })
		end),
	},
}

M.copilot_provider = copilot_provider

----------------------------------------------------------------------
-- Provider registration
----------------------------------------------------------------------

local function noop_action(provider_name, group, action)
	return function()
		vim.notify(
			string.format("%s: %s.%s is not supported by this AI provider", provider_name, group, action),
			vim.log.levels.WARN
		)
	end
end

-- Register a custom AI provider. Only the suggest/chat actions it actually
-- implements need defining -- any left out (e.g. a chat-only assistant with
-- no inline suggestions) are auto-filled with a no-op that just notifies
-- "not supported", instead of callers erroring on a missing field.
function M.register_provider(provider)
	assert(type(provider) == "table" and provider.name, "ai provider must be a table with a .name")

	for _, group in ipairs(SCHEMA_GROUPS) do
		provider[group] = provider[group] or {}
		for action in pairs(copilot_provider[group]) do
			if type(provider[group][action]) ~= "function" then
				provider[group][action] = noop_action(provider.name, group, action)
			end
		end
	end

	table.insert(custom_providers, provider)
	return provider
end

M.providers = custom_providers

-- Ask each registered provider (in registration order) whether it wants to
-- handle the current buffer/context; the first match wins. Copilot is the
-- fallback when nothing claims it.
function M.get_active_provider()
	for _, provider in ipairs(custom_providers) do
		if provider.is_active and provider.is_active() then
			return provider
		end
	end
	return copilot_provider
end

-- Back-compat alias (matches config.vcs's naming)
M.current = M.get_active_provider

return M
