----------------------------------------------------------------------
-- VCS abstraction
--
-- Hunk/diff/history/blame operations and the Telescope VCS pickers are
-- routed through here instead of calling gitsigns/diffview/telescope
-- directly, so a different backend can be swapped in later by adding
-- another entry to `backends` and setting profile.vcs.
----------------------------------------------------------------------

local M = {}

local backends = {}

backends.git = {
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
		-- Inline per-line blame toggle (<leader>gb)
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
		-- Commit history scoped to the current file (<leader>gtb)
		file_history = function()
			require("telescope.builtin").git_bcommits()
		end,
	},
}

M.backends = backends

function M.current()
	local name = require("profile").get().vcs or "git"
	return backends[name] or backends.git
end

return M
