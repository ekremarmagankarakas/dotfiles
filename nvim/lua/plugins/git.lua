return {
	----------------------------------------------------------------------
	-- Git Signs
	--
	-- Keymaps that dispatch through config.vcs (hunk nav/stage/blame, ih
	-- textobject) live in lua/config/vcs_keymaps.lua, not here -- they need
	-- to exist independent of whether this plugin is enabled. Only this
	-- plugin's own display/behavior config stays in this spec.
	----------------------------------------------------------------------
	{
		"lewis6991/gitsigns.nvim",
		cond = function()
			return require("profile").plugin_enabled("gitsigns.nvim")
		end,
		main = "gitsigns",
		event = "BufReadPre",
		opts = {
			current_line_blame_opts = {
				use_focus = false,
			},
			current_line_blame_formatter = "  <abbrev_sha> · <author> · <author_time:%Y-%m-%d> · <summary>",
		},
	},

	----------------------------------------------------------------------
	-- DiffView
	--
	-- Keymaps that dispatch through config.vcs (open/close/history/toggle)
	-- live in lua/config/vcs_keymaps.lua. The conflict-resolution keymaps
	-- below stay here since they're Diffview-view-local, not part of the
	-- VCS abstraction.
	----------------------------------------------------------------------
	{
		"sindrets/diffview.nvim",
		cond = function()
			return require("profile").plugin_enabled("diffview.nvim")
		end,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewRefresh",
			"DiffviewFileHistory",
		},
		opts = {
			hooks = {
				diff_buf_read = function(bufnr)
					vim.opt_local.wrap = false
					vim.opt_local.list = false
					vim.opt_local.relativenumber = false
					vim.opt_local.cursorline = false
				end,
				view_opened = function(view)
					vim.notify("DiffView opened", vim.log.levels.INFO)
				end,
			},
			keymaps = {
				view = {
					{ "n", "<leader>dco", "<cmd>lua require('diffview.actions').conflict_choose('ours')<cr>", { desc = "Choose ours" } },
					{ "n", "<leader>dct", "<cmd>lua require('diffview.actions').conflict_choose('theirs')<cr>", { desc = "Choose theirs" } },
					{ "n", "<leader>dcb", "<cmd>lua require('diffview.actions').conflict_choose('base')<cr>", { desc = "Choose base" } },
					{ "n", "<leader>dca", "<cmd>lua require('diffview.actions').conflict_choose('all')<cr>", { desc = "Choose all" } },
					{ "n", "dx", "<cmd>lua require('diffview.actions').conflict_choose('none')<cr>", { desc = "Delete conflict region" } },
				},
			},
		},
	},
}
