return {
	"L3MON4D3/LuaSnip",
	cond = function()
		return require("profile").plugin_enabled("LuaSnip")
	end,
	version = "v2.*",
	build = "make install_jsregexp",
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	config = function()
		local ls = require("luasnip")

		require("luasnip.loaders.from_vscode").lazy_load()
		local s = ls.snippet
		local t = ls.text_node
		local i = ls.insert_node

		----------------------------------------------------------------------
		-- Snippet navigation
		----------------------------------------------------------------------
		vim.keymap.set({ "i", "s" }, "<C-j>", function()
			if ls.expand_or_jumpable() then
				ls.expand_or_jump()
			end
		end, { silent = true, desc = "LuaSnip: expand/jump" })

		vim.keymap.set({ "i", "s" }, "<C-k>", function()
			if ls.jumpable(-1) then
				ls.jump(-1)
			end
		end, { silent = true, desc = "LuaSnip: jump back" })

		----------------------------------------------------------------------
		-- Global snippets (all filetypes)
		----------------------------------------------------------------------
		ls.add_snippets("all", {
			s("#f", {
				t("#files:`**/*."),
				i(1),
				t("`"),
			}),
		})

		ls.add_snippets("all", {
			s("#fd", {
				t({
					"#files:`**/*.py`",
					"#files:`**/*.js`",
					"#files:`**/*.jsx`",
					"#files:`**/*.html`",
					"#files:`**/*.css`",
				}),
			}),
		})
	end,
}
