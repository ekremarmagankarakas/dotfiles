----------------------------------------------------------------------
-- VCS abstraction
--
-- Hunk/diff/history/blame operations and the Telescope VCS pickers are
-- routed through here instead of calling gitsigns/diffview/telescope
-- directly. Git is the static, always-available fallback; anything else
-- (jj, hg, ...) registers itself with M.register_provider and implements
-- is_active() to say when it should take over for the current buffer/cwd.
-- get_active_provider() checks registered providers in registration order
-- and falls back to the git provider -- it never consults a static config
-- value, so multiple providers can coexist and the right one is picked per
-- buffer.
--
-- The keymaps that call into this (lua/config/vcs_keymaps.lua) are always
-- loaded, independent of whether gitsigns.nvim/diffview.nvim/telescope.nvim
-- are enabled -- so the git provider's own functions below guard every call
-- into those plugins and notify instead of erroring if one isn't loaded.
----------------------------------------------------------------------

local M = {}

-- Registered custom providers, in registration order (NOT git -- git is the
-- static fallback below and is never part of this list or its is_active scan).
local custom_providers = {}

local SCHEMA_GROUPS = { "hunk", "diff", "blame", "pickers" }

----------------------------------------------------------------------
-- Guards: call into an optional module/command without erroring if it
-- isn't loaded (e.g. its owning plugin is disabled via profile).
----------------------------------------------------------------------

-- Wrap fn(mod, ...) so it only runs if `mod_name` is require-able, else
-- notifies instead of raising.
local function with_module(mod_name, fn)
	return function(...)
		local ok, mod = pcall(require, mod_name)
		if not ok then
			vim.notify(
				string.format("git: %s is not loaded (plugin disabled?)", mod_name),
				vim.log.levels.WARN
			)
			return
		end
		return fn(mod, ...)
	end
end

-- Same idea for a plain ex-command (Diffview isn't a Lua API we require()).
-- `vim.fn.exists(":Cmd")` is true for lazy.nvim's placeholder too, so this
-- still lets the plugin lazy-load on first use -- it only fails closed when
-- the plugin was never going to load at all (disabled via profile).
local function with_command(build_cmd)
	return function(...)
		local cmd = build_cmd(...)
		local name = cmd:match("^%S+")
		if vim.fn.exists(":" .. name) ~= 2 then
			vim.notify(
				string.format("git: %s is not available (diffview.nvim disabled?)", name),
				vim.log.levels.WARN
			)
			return
		end
		vim.cmd(cmd)
	end
end

----------------------------------------------------------------------
-- Built-in Git provider (the fallback; always available, no is_active check)
----------------------------------------------------------------------
local git_provider = {
	name = "git",

	hunk = {
		preview = with_module("gitsigns", function(gs)
			gs.preview_hunk()
		end),
		preview_inline = with_module("gitsigns", function(gs)
			gs.preview_hunk_inline()
		end),
		next = with_module("gitsigns", function(gs)
			gs.nav_hunk("next")
		end),
		prev = with_module("gitsigns", function(gs)
			gs.nav_hunk("prev")
		end),
		stage = with_module("gitsigns", function(gs, range)
			gs.stage_hunk(range)
		end),
		reset = with_module("gitsigns", function(gs, range)
			gs.reset_hunk(range)
		end),
		stage_buffer = with_module("gitsigns", function(gs)
			gs.stage_buffer()
		end),
		reset_buffer = with_module("gitsigns", function(gs)
			gs.reset_buffer()
		end),
		undo_stage = with_module("gitsigns", function(gs)
			gs.undo_stage_hunk()
		end),
		select = with_module("gitsigns", function(gs)
			gs.select_hunk()
		end),
		toggle_signs = with_module("gitsigns", function(gs)
			gs.toggle_signs()
		end),
	},

	diff = {
		open = with_command(function()
			return "DiffviewOpen"
		end),
		close = with_command(function()
			return "DiffviewClose"
		end),
		toggle_files = with_command(function()
			return "DiffviewToggleFiles"
		end),
		history_all = with_command(function()
			return "DiffviewFileHistory"
		end),
		history_file = with_command(function()
			return "DiffviewFileHistory %"
		end),
	},

	blame = {
		-- Full commit/CL description popup for the current line (<leader>gb)
		line_full = with_module("gitsigns", function(gs)
			gs.blame_line({ full = true })
		end),
		-- Inline per-line blame toggle (<leader>gtb)
		toggle_line = with_module("gitsigns", function(gs)
			gs.toggle_current_line_blame()
		end),
		-- Full-buffer blame view (<leader>gB)
		buffer = with_module("gitsigns", function(gs)
			gs.blame()
		end),
	},

	pickers = {
		commits = with_module("telescope.builtin", function(tb)
			tb.git_commits()
		end),
		status = with_module("telescope.builtin", function(tb)
			tb.git_status()
		end),
		branches = with_module("telescope.builtin", function(tb)
			tb.git_branches()
		end),
	},
}

M.git_provider = git_provider

----------------------------------------------------------------------
-- Provider registration
----------------------------------------------------------------------

local function noop_action(provider_name, group, action)
	return function()
		vim.notify(
			string.format("%s: %s.%s is not supported by this VCS provider", provider_name, group, action),
			vim.log.levels.WARN
		)
	end
end

-- Register a custom VCS provider. Only the hunk/diff/blame/pickers actions
-- it actually implements need defining -- any left out (e.g. a VCS with no
-- staging area skipping hunk.stage) are auto-filled with a no-op that just
-- notifies "not supported", instead of callers erroring on a missing field.
function M.register_provider(provider)
	assert(type(provider) == "table" and provider.name, "vcs provider must be a table with a .name")

	for _, group in ipairs(SCHEMA_GROUPS) do
		provider[group] = provider[group] or {}
		for action in pairs(git_provider[group]) do
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
-- handle the current buffer/cwd; the first match wins. Git is the fallback
-- when nothing claims it.
function M.get_active_provider()
	for _, provider in ipairs(custom_providers) do
		if provider.is_active and provider.is_active() then
			return provider
		end
	end
	return git_provider
end

-- Back-compat alias
M.current = M.get_active_provider

return M
