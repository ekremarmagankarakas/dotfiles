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
----------------------------------------------------------------------

local M = {}

-- Registered custom providers, in registration order (NOT git -- git is the
-- static fallback below and is never part of this list or its is_active scan).
local custom_providers = {}

local SCHEMA_GROUPS = { "hunk", "diff", "blame", "pickers" }

----------------------------------------------------------------------
-- Built-in Git provider (the fallback; always available, no is_active check)
----------------------------------------------------------------------
local git_provider = {
	name = "git",

	hunk = {
		preview = function()
			require("gitsigns").preview_hunk()
		end,
		preview_inline = function()
			require("gitsigns").preview_hunk_inline()
		end,
		next = function()
			require("gitsigns").nav_hunk("next")
		end,
		prev = function()
			require("gitsigns").nav_hunk("prev")
		end,
		stage = function(range)
			require("gitsigns").stage_hunk(range)
		end,
		reset = function(range)
			require("gitsigns").reset_hunk(range)
		end,
		stage_buffer = function()
			require("gitsigns").stage_buffer()
		end,
		reset_buffer = function()
			require("gitsigns").reset_buffer()
		end,
		undo_stage = function()
			require("gitsigns").undo_stage_hunk()
		end,
		select = function()
			require("gitsigns").select_hunk()
		end,
		toggle_signs = function()
			require("gitsigns").toggle_signs()
		end,
	},

	diff = {
		open = function()
			vim.cmd("DiffviewOpen")
		end,
		close = function()
			vim.cmd("DiffviewClose")
		end,
		toggle_files = function()
			vim.cmd("DiffviewToggleFiles")
		end,
		history_all = function()
			vim.cmd("DiffviewFileHistory")
		end,
		history_file = function()
			vim.cmd("DiffviewFileHistory %")
		end,
	},

	blame = {
		-- Full commit/CL description popup for the current line (<leader>gb)
		line_full = function()
			require("gitsigns").blame_line({ full = true })
		end,
		-- Inline per-line blame toggle (<leader>gtb)
		toggle_line = function()
			require("gitsigns").toggle_current_line_blame()
		end,
		-- Full-buffer blame view (<leader>gB)
		buffer = function()
			require("gitsigns").blame()
		end,
	},

	pickers = {
		commits = function()
			require("telescope.builtin").git_commits()
		end,
		status = function()
			require("telescope.builtin").git_status()
		end,
		branches = function()
			require("telescope.builtin").git_branches()
		end,
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
