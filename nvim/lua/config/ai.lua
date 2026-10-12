----------------------------------------------------------------------
-- AI assistant abstraction
--
-- Inline-suggestion and chat operations are routed through here instead of
-- calling copilot.lua/CopilotChat.nvim directly. Unlike config.vcs, there is
-- NO static default provider -- git is a sane universal fallback for VCS,
-- but there's no equivalent "obviously correct" AI assistant, and Copilot
-- is off by default in every profile anyway. If nothing is active,
-- get_active_provider() returns nil and the keymaps just say so.
--
-- Copilot is registered below like any other provider would be: it's only
-- "active" when its own plugin toggle says so. Register more providers
-- (CodeCompanion, avante.nvim, a Claude-based chat plugin, ...) the same
-- way, from any module, via M.register_provider.
--
-- The keymaps that call into this (lua/config/ai_keymaps.lua) are always
-- loaded, independent of whether copilot.lua/CopilotChat.nvim are enabled
-- via profile -- so Copilot's own functions below guard every call into
-- those plugins and notify instead of erroring if one isn't loaded.
--
-- NOT part of this abstraction: the ghost-text accept/next/prev/dismiss
-- insert-mode keys (copilot.lua's own `opts.suggestion.keymap`) and
-- CopilotChat's chat-buffer-local accept/show/yank-diff keys (its own
-- `opts.mappings`). Those are each plugin's tightly-coupled internal UI --
-- a different provider would wire its own equivalent independently, same
-- as Diffview's conflict-resolution keymaps stayed plugin-local for VCS.
----------------------------------------------------------------------

local M = {}

-- Registered providers, in registration order.
local providers = {}

-- The stable suggest/chat action names every provider is measured against.
-- Deliberately not derived from any one provider's implementation table --
-- there's no privileged "default" provider here to borrow a schema from.
local SCHEMA = {
	suggest = { "toggle", "enable", "disable", "toggle_auto_trigger" },
	chat = { "toggle", "fix", "refactor", "explain", "tests" },
}

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

-- Register an AI provider. Only the suggest/chat actions it actually
-- implements need defining -- any left out (e.g. a chat-only assistant
-- with no inline suggestions) are auto-filled with a no-op that just
-- notifies "not supported", instead of callers erroring on a missing field.
function M.register_provider(provider)
	assert(type(provider) == "table" and provider.name, "ai provider must be a table with a .name")

	for group, actions in pairs(SCHEMA) do
		provider[group] = provider[group] or {}
		for _, action in ipairs(actions) do
			if type(provider[group][action]) ~= "function" then
				provider[group][action] = noop_action(provider.name, group, action)
			end
		end
	end

	table.insert(providers, provider)
	return provider
end

M.providers = providers

-- Ask each registered provider (in registration order) whether it's
-- active; the first match wins. No match == no AI provider at all --
-- there's no implicit fallback.
function M.get_active_provider()
	for _, provider in ipairs(providers) do
		if provider.is_active and provider.is_active() then
			return provider
		end
	end
	return nil
end

-- Back-compat alias (matches config.vcs's naming)
M.current = M.get_active_provider

----------------------------------------------------------------------
-- Copilot: registered the same way any other provider would be. Active
-- only when at least one of its two plugins is actually enabled.
----------------------------------------------------------------------
local copilot_auto_trigger = false

M.register_provider({
	name = "copilot",

	is_active = function()
		local profile = require("profile")
		return profile.plugin_enabled("copilot.lua") or profile.plugin_enabled("CopilotChat.nvim")
	end,

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
})

return M
