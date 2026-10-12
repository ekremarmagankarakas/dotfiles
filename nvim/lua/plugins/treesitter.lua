----------------------------------------------------------------------
-- TreeSitter
----------------------------------------------------------------------
return {
	"nvim-treesitter/nvim-treesitter",
	-- Pin to "master" (the legacy configs-style API this file is written
	-- against). The config function below still detects and falls back to
	-- the "main" branch's slimmed-down API if that's what's installed.
	branch = "master",
	build = ":TSUpdate",
	cond = function()
		return require("profile").plugin_enabled("nvim-treesitter")
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
		"windwp/nvim-ts-autotag",
		{ "nvim-treesitter/nvim-treesitter-context", opts = { max_lines = 3 } },
	},
	config = function()
		-- YANG has no maintained treesitter grammar; register the filetype
		-- anyway so LSP/formatter/other filetype-keyed tooling can target it.
		vim.filetype.add({ extension = { yang = "yang" } })

		local parsers = {
			"vimdoc",
			"javascript",
			"typescript",
			"c",
			"cpp",
			"lua",
			"rust",
			"go",
			"gomod",
			"gosum",
			"jsdoc",
			"bash",
			"latex",
			"bibtex",
			"r",
			"markdown",
			"markdown_inline",
			"zig",
			"python",
			"php",
			"sql",
			"css",
			"html",
		}

		local max_filesize = 100 * 1024
		local function is_large(buf)
			local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				vim.notify(
					"File larger than 100KB, treesitter disabled for performance",
					vim.log.levels.WARN,
					{ title = "Treesitter" }
				)
				return true
			end
			return false
		end

		local ts = require("nvim-treesitter")

		if ts.setup then
			----------------------------------------------------------------------
			-- "master" branch: legacy configs-style API
			----------------------------------------------------------------------
			ts.setup({
				ensure_installed = parsers,
				sync_install = false,
				auto_install = true,
				indent = { enable = true },
				highlight = {
					enable = true,
					disable = function(lang, buf)
						if lang == "markdown" or lang == "markdown_inline" then
							return true
						end
						return is_large(buf)
					end,
					additional_vim_regex_highlighting = { "markdown" },
				},
			})
		else
			----------------------------------------------------------------------
			-- "main" branch: new slim API, no configs/highlight/indent modules
			----------------------------------------------------------------------
			ts.install(parsers)

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf = args.buf
					local ft = vim.bo[buf].filetype
					local lang = vim.treesitter.language.get_lang(ft) or ft

					if lang == "markdown" or lang == "markdown_inline" or is_large(buf) then
						return
					end

					if not (ts.get_installed and vim.tbl_contains(ts.get_installed(), lang)) then
						pcall(ts.install, { lang })
					end

					pcall(vim.treesitter.start, buf, lang)
				end,
			})
		end

		-- Auto-close and auto-rename HTML/JSX tags
		require("nvim-ts-autotag").setup()

		-- Set up textobjects keymaps manually (required for newer nvim-treesitter,
		-- and identical on both the "main" and "master" branches)
		local ts_select = require("nvim-treesitter-textobjects.select")
		local ts_move = require("nvim-treesitter-textobjects.move")

		-- Select
		local select_maps = {
			["af"] = "@function.outer",
			["if"] = "@function.inner",
			["ac"] = "@class.outer",
			["ic"] = "@class.inner",
			["aa"] = "@parameter.outer",
			["ia"] = "@parameter.inner",
			["ai"] = "@conditional.outer",
			["ii"] = "@conditional.inner",
			["al"] = "@loop.outer",
			["il"] = "@loop.inner",
		}
		for key, query in pairs(select_maps) do
			vim.keymap.set({ "x", "o" }, key, function()
				ts_select.select_textobject(query, "textobjects")
			end, { desc = "TS: " .. query })
		end

		-- Move
		local move_maps = {
			["]m"] = { fn = ts_move.goto_next_start, query = "@function.outer", desc = "Next function start" },
			["]M"] = { fn = ts_move.goto_next_end, query = "@function.outer", desc = "Next function end" },
			["]]"] = { fn = ts_move.goto_next_start, query = "@class.outer", desc = "Next class start" },
			["]["] = { fn = ts_move.goto_next_end, query = "@class.outer", desc = "Next class end" },
			["]a"] = { fn = ts_move.goto_next_start, query = "@parameter.inner", desc = "Next argument" },
			["[m"] = { fn = ts_move.goto_previous_start, query = "@function.outer", desc = "Prev function start" },
			["[M"] = { fn = ts_move.goto_previous_end, query = "@function.outer", desc = "Prev function end" },
			["[["] = { fn = ts_move.goto_previous_start, query = "@class.outer", desc = "Prev class start" },
			["[]"] = { fn = ts_move.goto_previous_end, query = "@class.outer", desc = "Prev class end" },
			["[a"] = { fn = ts_move.goto_previous_start, query = "@parameter.inner", desc = "Prev argument" },
		}
		for key, map in pairs(move_maps) do
			vim.keymap.set({ "n", "x", "o" }, key, function()
				map.fn(map.query, "textobjects")
			end, { desc = map.desc })
		end
	end,
}
