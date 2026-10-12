return {
	----------------------------------------------------------------------
	-- Git Signs
	----------------------------------------------------------------------
	{
		"lewis6991/gitsigns.nvim",
		cond = function()
			return require("profile").plugin_enabled("gitsigns.nvim")
		end,
		main = "gitsigns",
		event = "BufReadPre",
		keys = {
			-- Preview
			{
				"<leader>gp",
				function()
					require("config.vcs").current().hunk.preview()
				end,
				silent = true,
				desc = "Git: preview hunk",
			},
			{
				"<leader>gP",
				function()
					require("config.vcs").current().hunk.preview_inline()
				end,
				silent = true,
				desc = "Git: preview hunk inline",
			},

			-- Hunk navigation
			{
				"]g",
				function()
					require("config.vcs").current().hunk.next()
				end,
				silent = true,
				desc = "Git: next hunk",
			},
			{
				"[g",
				function()
					require("config.vcs").current().hunk.prev()
				end,
				silent = true,
				desc = "Git: prev hunk",
			},

			-- Stage / Reset (normal + visual)
			{
				"<leader>gs",
				function()
					require("config.vcs").current().hunk.stage()
				end,
				silent = true,
				desc = "Git: stage hunk",
			},
			{
				"<leader>gs",
				function()
					require("config.vcs").current().hunk.stage({ vim.fn.line("."), vim.fn.line("v") })
				end,
				mode = "v",
				silent = true,
				desc = "Git: stage hunk (visual)",
			},
			{
				"<leader>gr",
				function()
					require("config.vcs").current().hunk.reset()
				end,
				silent = true,
				desc = "Git: reset hunk",
			},
			{
				"<leader>gr",
				function()
					require("config.vcs").current().hunk.reset({ vim.fn.line("."), vim.fn.line("v") })
				end,
				mode = "v",
				silent = true,
				desc = "Git: reset hunk (visual)",
			},
			{
				"<leader>gS",
				function()
					require("config.vcs").current().hunk.stage_buffer()
				end,
				silent = true,
				desc = "Git: stage buffer",
			},
			{
				"<leader>gR",
				function()
					require("config.vcs").current().hunk.reset_buffer()
				end,
				silent = true,
				desc = "Git: reset buffer",
			},
			{
				"<leader>gu",
				function()
					require("config.vcs").current().hunk.undo_stage()
				end,
				silent = true,
				desc = "Git: undo stage hunk",
			},

			-- Blame
			{
				"<leader>gb",
				function()
					require("config.vcs").current().blame.toggle_line()
				end,
				silent = true,
				desc = "Git: toggle line blame",
			},
			{
				"<leader>gB",
				function()
					require("config.vcs").current().blame.buffer()
				end,
				silent = true,
				desc = "Git: full buffer blame",
			},

			-- Toggles
			{
				"<leader>gT",
				function()
					require("config.vcs").current().hunk.toggle_signs()
				end,
				silent = true,
				desc = "Git: toggle signs",
			},
		},
		opts = {
			current_line_blame_opts = {
				use_focus = false,
			},
			current_line_blame_formatter = "  <abbrev_sha> · <author> · <author_time:%Y-%m-%d>",
			on_attach = function(bufnr)
				vim.keymap.set({ "o", "x" }, "ih", function()
					require("config.vcs").current().hunk.select()
				end, { buffer = bufnr, desc = "Git: select hunk" })
			end,
		},
	},

	----------------------------------------------------------------------
	-- DiffView
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
		keys = {
			{
				"<leader>gdo",
				function()
					require("config.vcs").current().diff.open()
				end,
				desc = "Open Diffview",
			},
			{
				"<leader>gdc",
				function()
					require("config.vcs").current().diff.close()
				end,
				desc = "Close Diffview",
			},
			{
				"<leader>gdh",
				function()
					require("config.vcs").current().diff.history_all()
				end,
				desc = "File History (all)",
			},
			{
				"<leader>gdf",
				function()
					require("config.vcs").current().diff.history_file()
				end,
				desc = "File History (current)",
			},
			{
				"<leader>gdt",
				function()
					require("config.vcs").current().diff.toggle_files()
				end,
				desc = "Toggle File Panel",
			},
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
