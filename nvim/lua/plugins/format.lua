return {
	"stevearc/conform.nvim",
	cond = function()
		return require("profile").plugin_enabled("conform.nvim")
	end,
	keys = {
		{
			"<leader>lf",
			function()
				require("conform").format()
			end,
			desc = "Format file",
		},
	},
	opts = function()
		local profile = require("profile")

		local formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_format" },
			c = { "clang_format" },
			cpp = { "clang_format" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			javascriptreact = { "prettier" },
			go = { "goimports", "gofumpt" },
			rust = { "rustfmt" },
			zig = { "zigfmt" },
			bash = { "shfmt" },
			sh = { "shfmt" },
			markdown = { "prettier" },
			php = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			less = { "prettier" },
			html = { "prettier" },
			sql = { "sqlfmt" },
			r = { "r_styler" },
			tex = { "tex_fmt" },
			latex = { "tex_fmt" },
		}

		for ft in pairs(formatters_by_ft) do
			if not profile.format_enabled(ft) then
				formatters_by_ft[ft] = nil
			end
		end

		formatters_by_ft = vim.tbl_deep_extend("force", formatters_by_ft, profile.extra("formatters_by_ft"))

		local formatters = {
			ruff_format = {
				command = "ruff",
				args = { "format", "--stdin-filename", "$FILENAME", "-" },
				stdin = true,
			},
			prettier = { prepend_args = { "--tab-width", "2", "--use-tabs", "false" } },
			clang_format = { prepend_args = { "--style={BasedOnStyle: Google, ColumnLimit: 80, InsertBraces: true}" } },
			stylua = { prepend_args = { "--indent-width", "4" } },
			shfmt = { prepend_args = { "-i", "4" } },
			tex_fmt = {
				command = "tex-fmt",
				args = { "--stdin" },
				stdin = true,
			},
			r_styler = {
				command = "Rscript",
				args = {
					"-e",
					"styler::style_file(commandArgs(trailingOnly = TRUE)[1])",
					"$FILENAME",
				},
				stdin = false,
			},
		}

		formatters = vim.tbl_deep_extend("force", formatters, profile.extra("formatters"))

		return {
			formatters_by_ft = formatters_by_ft,
			default_format_opts = {
				lsp_format = "fallback",
			},
			formatters = formatters,
		}
	end,
}
