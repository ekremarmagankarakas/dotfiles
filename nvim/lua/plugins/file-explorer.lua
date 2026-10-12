return {
	----------------------------------------------------------------------
	-- Oil (edit filesystem as a buffer)
	----------------------------------------------------------------------
	{
		"stevearc/oil.nvim",
		cond = function()
			return require("profile").plugin_enabled("oil.nvim")
		end,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = false,
		keys = {
			{ "-", "<cmd>Oil<cr>", desc = "Oil: open parent directory" },
			{ "<leader>n", "<cmd>Oil<cr>", desc = "Oil: open parent directory" },
		},
		opts = {
			default_file_explorer = true,
			columns = { "icon" },
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			watch_for_changes = true,
			view_options = {
				show_hidden = true,
			},
			win_options = {
				signcolumn = "yes:2",
			},
		},
	},

	----------------------------------------------------------------------
	-- Oil Git Status (git status signs in Oil listings)
	----------------------------------------------------------------------
	{
		"refractalize/oil-git-status.nvim",
		cond = function()
			return require("profile").plugin_enabled("oil-git-status.nvim")
		end,
		dependencies = { "stevearc/oil.nvim" },
		opts = {},
	},
}
