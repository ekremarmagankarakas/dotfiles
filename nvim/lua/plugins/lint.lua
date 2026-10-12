return {
	"mfussenegger/nvim-lint",
	cond = function()
		return require("profile").plugin_enabled("nvim-lint")
	end,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			python = { "ruff" },
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			sh = { "shellcheck" },
			bash = { "shellcheck" },
		}

		-- eslint config files to check for
		local eslint_configs = {
			".eslintrc",
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.json",
			"eslint.config.js",
			"eslint.config.mjs",
			"eslint.config.cjs",
			"eslint.config.ts",
			"eslint.config.mts",
			"eslint.config.cts",
		}

		--- Check if eslint is configured for the current project
		local function has_eslint_config(bufnr)
			local fname = vim.api.nvim_buf_get_name(bufnr)
			return vim.fs.find(eslint_configs, {
				path = vim.fs.dirname(fname),
				upward = true,
				stop = vim.uv.os_homedir(),
			})[1] ~= nil
		end

		-- Auto-lint on save, insert leave, and after reading a file
		local lint_group = vim.api.nvim_create_augroup("NvimLint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "BufReadPost" }, {
			group = lint_group,
			callback = function(args)
				if vim.bo[args.buf].buftype ~= "" then
					return
				end

				local ft = vim.bo[args.buf].filetype
				local js_fts = { javascript = true, typescript = true, typescriptreact = true, javascriptreact = true }

				-- Skip eslint_d if no config found
				if js_fts[ft] and not has_eslint_config(args.buf) then
					return
				end

				lint.try_lint()
			end,
		})

		-- Manual lint keymap
		vim.keymap.set("n", "<leader>ll", function()
			lint.try_lint()
		end, { desc = "Lint: run linters" })
	end,
}
