-- Mason package name for each Mason-managed LSP server, so profile.lsp.servers
-- toggles can filter the mason-tool-installer ensure_installed list too.
-- r_language_server is installed via R itself, not Mason, so it has no entry.
local SERVER_TOOLS = {
	lua_ls = "lua-language-server",
	pyright = "pyright",
	ts_ls = "typescript-language-server",
	zls = "zls",
	ltex = "ltex-ls",
	marksman = "marksman",
	clangd = "clangd",
	rust_analyzer = "rust-analyzer",
	gopls = "gopls",
	bashls = "bash-language-server",
	intelephense = "intelephense",
	sqls = "sqls",
	cssls = "css-lsp",
	html = "html-lsp",
}

local ALL_SERVERS = {
	"lua_ls", "pyright", "ts_ls", "zls", "ltex", "marksman", "clangd",
	"rust_analyzer", "gopls", "bashls", "intelephense", "sqls", "cssls", "html",
}

return {
	"neovim/nvim-lspconfig",
	version = "*",
	cond = function()
		return require("profile").plugin_enabled("nvim-lspconfig")
	end,
	dependencies = {
		-- Mason
		{
			"mason-org/mason.nvim",
			cond = function()
				return require("profile").plugin_enabled("mason.nvim")
			end,
			opts = {},
		},
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			cond = function()
				return require("profile").plugin_enabled("mason-tool-installer.nvim")
			end,
			opts = function()
				local profile = require("profile")
				local ensure_installed = {}

				if profile.plugin_enabled("format") then
					vim.list_extend(ensure_installed, {
						"stylua", "prettier", "shfmt", "goimports", "gofumpt", "clang-format", "sqlfmt",
					})
				end

				if profile.plugin_enabled("lint") then
					vim.list_extend(ensure_installed, { "ruff", "eslint_d", "shellcheck" })
				end

				if profile.plugin_enabled("debug") then
					vim.list_extend(ensure_installed, { "debugpy", "delve", "js-debug-adapter", "codelldb" })
				end

				for _, server in ipairs(ALL_SERVERS) do
					if profile.lsp_server_enabled(server) then
						table.insert(ensure_installed, SERVER_TOOLS[server])
					end
				end

				return { ensure_installed = ensure_installed }
			end,
		},
		-- Completion
		{ "hrsh7th/nvim-cmp", event = { "InsertEnter", "CmdlineEnter" } },
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"saadparwaiz1/cmp_luasnip",
	},

	-- Lets gitignored/other modules hook into capabilities and register
	-- additional LSP servers without editing this file: see profile.extra
	-- ("lsp_update_capabilities", "lsp_extra_setup").
	opts = function()
		local profile = require("profile")
		return {
			update_capabilities = profile.extra("lsp_update_capabilities"),
			extra_setup = profile.extra("lsp_extra_setup"),
		}
	end,

	config = function(_, opts)
		--------------------------------------------------------------------------
		-- CMP
		--------------------------------------------------------------------------
		local cmp = require("cmp")
		local cmp_lsp = require("cmp_nvim_lsp")

		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
				["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources(
				vim.list_extend(
					{ { name = "nvim_lsp" }, { name = "luasnip" }, { name = "path" } },
					require("profile").extra("completion_sources")
				),
				{ { name = "buffer" } }
			),
		})

		-- Cmdline completion for "/" and "?" (search)
		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		-- Cmdline completion for ":" (command)
		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
			matching = { disallow_symbol_nonprefix_matching = false },
		})

		local cmp_enabled = true
		vim.keymap.set("n", "<leader>ltc", function()
			cmp_enabled = not cmp_enabled
			cmp.setup({ enabled = cmp_enabled })
			vim.notify("Suggestions: " .. (cmp_enabled and "ENABLED" or "DISABLED"), vim.log.levels.INFO)
		end, { silent = true, desc = "Completion: toggle suggestions" })

		----------------------------------------------------------------------
		-- LSP core
		----------------------------------------------------------------------
		local capabilities = cmp_lsp.default_capabilities()
		for _, update_capabilities in ipairs(opts.update_capabilities) do
			capabilities = update_capabilities(capabilities) or capabilities
		end

		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		-- LSP keymaps
		-- Neovim 0.11+ ships default LSP keymaps (gra, grn, grr, gri, gO, K, ...);
		-- these are kept explicit anyway so they show up in which-key / :Telescope keymaps
		-- and so their behavior doesn't silently change across Neovim versions.
		local lsp_keymaps = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true })
		vim.api.nvim_create_autocmd("LspAttach", {
			group = lsp_keymaps,
			callback = function(ev)
				local bufnr = ev.buf
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
				end

				-- gd/gD/gy go to definition/declaration/type definition.
				-- grn/gra/grr/gri/gO (rename/code action/references/implementation/symbols)
				-- and K (hover) are Neovim 0.11+ LSP defaults; <leader>l* mirrors the common
				-- ones under the lsp which-key group, and signature help has no default.
				map("n", "gd", vim.lsp.buf.definition, "LSP: goto definition")
				map("n", "gD", vim.lsp.buf.declaration, "LSP: goto declaration")
				map("n", "gy", vim.lsp.buf.type_definition, "LSP: goto type definition")
				map("n", "K", vim.lsp.buf.hover, "LSP: hover")
				map("n", "<leader>lr", vim.lsp.buf.rename, "LSP: rename")
				map("n", "<leader>la", vim.lsp.buf.code_action, "LSP: code action")
				-- <C-k> is taken globally by LuaSnip jump-back, so signature help lives on <C-s>
				map("i", "<C-s>", vim.lsp.buf.signature_help, "LSP: signature help")
			end,
		})

		----------------------------------------------------------------------
		-- Server configs
		----------------------------------------------------------------------

		-- Lua
		vim.lsp.config("lua_ls", {
			filetypes = { "lua" },
			root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", "stylua.toml", ".stylua.toml", ".git" },
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = { globals = { "bit", "vim", "it", "describe", "before_each", "after_each" } },
					workspace = { checkThirdParty = false },
					hint = { enable = true },
				},
			},
		})

		-- Python
		local function get_python_path(workspace)
			-- 1. Respect VIRTUAL_ENV if already activated
			local venv = vim.env.VIRTUAL_ENV
			if venv then
				return venv .. "/bin/python"
			end

			-- 2. Auto-detect .venv in project root
			local venv_path = workspace .. "/.venv/bin/python"
			if vim.fn.executable(venv_path) == 1 then
				return venv_path
			end

			-- 3. Fallback to system python
			return vim.fn.exepath("python3") or "python"
		end

		vim.lsp.config("pyright", {
			filetypes = { "python" },
			root_markers = {
				"pyrightconfig.json",
				"pyproject.toml",
				"setup.py",
				"setup.cfg",
				"requirements.txt",
				"Pipfile",
				".git",
			},
			on_init = function(client)
				local root = client.config.root_dir or vim.fn.getcwd()
				local python_path = get_python_path(root)
				client.config.settings.python.pythonPath = python_path
			end,
			settings = {
				python = {
					analysis = {
						typeCheckingMode = "basic",
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
					},
				},
			},
		})

		-- TypeScript/JavaScript
		vim.lsp.config("ts_ls", {
			filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
			root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
			settings = {
				typescript = {
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayVariableTypeHintsWhenTypeMatchesName = false,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
				javascript = {
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayVariableTypeHintsWhenTypeMatchesName = false,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			},
		})

		-- LTEX
		vim.lsp.config("ltex", {
			filetypes = { "tex", "latex", "bib" },
			root_markers = { ".git" },
			settings = {
				ltex = {
					checkFrequency = "save",
					language = "en-US",
					enabled = { "tex", "latex", "bib" },
					disabledRules = { ["en-US"] = { "WHITESPACE_RULE" } },
				},
			},
		})

		-- Zig
		vim.lsp.config("zls", {
			filetypes = { "zig", "zir" },
			root_markers = { "zls.json", "build.zig", ".git" },
			settings = {
				zls = {
					enable_inlay_hints = true,
					enable_snippets = true,
					warn_style = true,
				},
			},
		})

		-- Marksman
		vim.lsp.config("marksman", {
			filetypes = { "markdown" },
			root_markers = { ".git", ".marksman.toml", "index.md" },
		})

		-- C/C++
		vim.lsp.config("clangd", {
			filetypes = { "c", "cpp", "objc", "objcpp" },
			root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--header-insertion=iwyu",
				"--completion-style=detailed",
				"--function-arg-placeholders=1",
			},
			init_options = {
				usePlaceholders = true,
				completeUnimported = true,
				clangdFileStatus = true,
			},
		})

		-- Rust
		vim.lsp.config("rust_analyzer", {
			filetypes = { "rust" },
			root_markers = { "Cargo.toml", "rust-project.json", ".git" },
			settings = {
				["rust-analyzer"] = {
					checkOnSave = { command = "clippy" },
					cargo = { allFeatures = true },
				},
			},
		})

		-- Go
		vim.lsp.config("gopls", {
			filetypes = { "go", "gomod", "gowork", "gotmpl" },
			root_markers = { "go.mod", "go.work", ".git" },
			settings = {
				gopls = {
					analyses = {
						unusedparams = true,
						shadow = true,
					},
					staticcheck = true,
					gofumpt = true,
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
				},
			},
		})

		-- Bash
		vim.lsp.config("bashls", {
			filetypes = { "sh", "bash" },
			root_markers = { ".git" },
		})

		-- PHP
		vim.lsp.config("intelephense", {
			filetypes = { "php" },
			root_markers = { "composer.json", ".git" },
		})

		-- SQL
		vim.lsp.config("sqls", {
			filetypes = { "sql", "mysql" },
			root_markers = { ".git" },
		})

		-- CSS
		vim.lsp.config("cssls", {
			filetypes = { "css", "scss", "less" },
			root_markers = { "package.json", ".git" },
		})

		-- HTML
		vim.lsp.config("html", {
			filetypes = { "html" },
			root_markers = { "package.json", ".git" },
		})

		-- Enable Mason-managed servers that are on for the active profile
		local enabled_servers = {}
		for _, server in ipairs(ALL_SERVERS) do
			if require("profile").lsp_server_enabled(server) then
				table.insert(enabled_servers, server)
			end
		end
		vim.lsp.enable(enabled_servers)

		-- Let other (possibly gitignored) modules register their own servers
		-- now that capabilities/built-in servers are set up.
		for _, extra_setup in ipairs(opts.extra_setup) do
			local ok, err = pcall(extra_setup, capabilities)
			if not ok then
				vim.notify("lsp: extra_setup hook failed: " .. tostring(err), vim.log.levels.WARN)
			end
		end

		-- R (installed via R, not Mason)
		-- Use autocmd to explicitly start server since it's not managed by Mason
		local r_lsp_group = vim.api.nvim_create_augroup("RLanguageServer", { clear = true })

		vim.api.nvim_create_autocmd("FileType", {
			group = r_lsp_group,
			pattern = { "r" },
			callback = function()
				if not require("profile").lsp_server_enabled("r_language_server") then
					return
				end

				-- Find git root or use cwd
				local root_dir = vim.fn.getcwd()
				local git = vim.fs.find(".git", { upward = true })[1]
				if git then
					root_dir = vim.fs.dirname(git)
				end

				vim.lsp.start({
					name = "r_language_server",
					cmd = { "R", "--slave", "-e", "languageserver::run()" },
					root_dir = root_dir,
				})
			end,
		})
	end,
}
