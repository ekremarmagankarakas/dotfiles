----------------------------------------------------------------------
-- VCS abstraction
--
-- Hunk/diff/history/blame operations and the Telescope VCS pickers are
-- routed through here instead of calling gitsigns/diffview/telescope
-- directly. Providers register themselves rather than being baked into a
-- fixed table, so a gitignored module can add another backend (jj, hg, ...)
-- via M.register_provider without touching this file; profile.vcs picks
-- which registered provider is active.
----------------------------------------------------------------------

local M = {}

local providers = {}

function M.register_provider(provider)
	assert(type(provider) == "table" and provider.name, "vcs provider must be a table with a .name")
	providers[provider.name] = provider
end

function M.get_active_provider()
	local name = require("profile").get().vcs or "git"
	return providers[name] or providers.git
end

-- Back-compat alias
M.current = M.get_active_provider

M.providers = providers

----------------------------------------------------------------------
-- Built-in Git provider
----------------------------------------------------------------------
M.register_provider({
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
})

return M
