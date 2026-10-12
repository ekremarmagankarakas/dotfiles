return {
	----------------------------------------------------------------------
	-- VimTex
	----------------------------------------------------------------------
	{
		"lervag/vimtex",
		cond = function()
			return require("profile").plugin_enabled("vimtex")
		end,
		ft = { "tex" },
		init = function()
			vim.g.vimtex_view_method = "general" -- use default
			vim.g.vimtex_compiler_method = "latexmk" -- default, explicit here
			vim.g.vimtex_quickfix_mode = 0 -- don't auto-open quickfix on warnings


			-- Put all generated files (including PDF) into ./out
			vim.g.vimtex_compiler_latexmk = {
				continuous = 1,
				out_dir = "out",
				options = { "-pdf", "-interaction=nonstopmode", "-synctex=1" },
			}
		end,
	},
}
