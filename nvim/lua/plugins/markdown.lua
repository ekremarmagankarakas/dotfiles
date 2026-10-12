return {
	{
		"jakewvincent/mkdnflow.nvim",
		cond = function()
			return require("profile").plugin_enabled("mkdnflow.nvim")
		end,
		ft = { "markdown", "rmd" },
		config = function()
			require("mkdnflow").setup({
				modules = { maps = false },
				on_attach = function(bufnr)
					local map = function(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
					end

					map("n", "<leader>mf", "<cmd>MkdnFollowLink<cr>", "Markdown: follow link")
					map("n", "<leader>mF", "<cmd>MkdnDestroyLink<cr>", "Markdown: destroy link")
					map({ "n", "v" }, "<leader>mc", "<cmd>MkdnCreateLink<cr>", "Markdown: create link")
					map(
						{ "n", "v" },
						"<leader>mC",
						"<cmd>MkdnCreateLinkFromClipboard<cr>",
						"Markdown: link from clipboard"
					)
					map("n", "<leader>mn", "<cmd>MkdnNextLink<cr>", "Markdown: next link")
					map("n", "<leader>mp", "<cmd>MkdnPrevLink<cr>", "Markdown: prev link")
					map("n", "<leader>mb", "<cmd>MkdnGoBack<cr>", "Markdown: back")
					map("n", "<leader>mB", "<cmd>MkdnGoForward<cr>", "Markdown: forward")
					map({ "n", "v" }, "<leader>mt", "<cmd>MkdnToggleToDo<cr>", "Markdown: toggle todo")
				end,
			})
		end,
	},
}
