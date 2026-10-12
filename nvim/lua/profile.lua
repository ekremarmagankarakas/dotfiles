----------------------------------------------------------------------
-- Profile system
--
-- Selects a named profile (personal, minimal, ...) and lets plugin specs,
-- LSP server setup, formatters, and vim.opt/vim.g settings query it for
-- per-profile behavior. Machine-local tweaks that shouldn't be committed
-- go in lua/profile_local.lua or lua/local/*.lua (both gitignored) and
-- are deep-merged on top of the selected named profile.
----------------------------------------------------------------------

local M = {}

local defaults = {
	-- Per-plugin enable/disable, keyed by the plugin's repo name (e.g. "copilot.lua").
	-- Unset == enabled.
	plugins = {},

	-- Plugin names to force-disable regardless of `plugins` above.
	disabled_plugins = {},

	lsp = {
		-- Per-server enable/disable, keyed by lspconfig server name. Unset == enabled.
		servers = {},
	},

	-- Per-filetype formatter enable/disable, keyed by filetype. Unset == enabled.
	format = {},

	-- vim.opt.<key> = value
	options = {},
	-- vim.g.<key> = value
	globals = {},

	-- Directories searched by <leader>fa
	search_dirs = { "~/Dev", "~/Northeastern", "~/Work" },

	-- VCS backend used by config.vcs (see lua/config/vcs.lua)
	vcs = "git",

	-- Additive extension points consumed by parameterized plugin specs.
	extra = {
		-- Extra nvim-cmp sources appended to the default list.
		completion_sources = {},
		-- Extra Telescope extension names to load.
		telescope_extensions = {},
		-- Extra conform.nvim formatters_by_ft entries, merged in.
		formatters_by_ft = {},
		-- Extra conform.nvim formatter definitions, merged in.
		formatters = {},
		-- Extra which-key groups: { { "<leader>x", group = "..." }, ... }
		whichkey_groups = {},
	},
}

local profiles = {
	personal = {
		plugins = {
			["copilot.lua"] = false,
			["CopilotChat.nvim"] = false,
		}
	},

	minimal = {
		plugins = {
			["copilot.lua"] = false,
			["CopilotChat.nvim"] = false,
			["nvim-dap"] = false,
			["vimtex"] = false,
			["mkdnflow.nvim"] = false,
			["diffview.nvim"] = false,
			["harpoon"] = false,
		},
		lsp = {
			servers = {
				pyright = false,
				ts_ls = false,
				zls = false,
				ltex = false,
				marksman = false,
				clangd = false,
				rust_analyzer = false,
				gopls = false,
				intelephense = false,
				sqls = false,
				cssls = false,
				html = false,
				r_language_server = false,
			},
		},
		format = {
			python = false,
			c = false,
			cpp = false,
			javascript = false,
			typescript = false,
			typescriptreact = false,
			javascriptreact = false,
			go = false,
			rust = false,
			zig = false,
			php = false,
			css = false,
			scss = false,
			less = false,
			html = false,
			sql = false,
			r = false,
			tex = false,
			latex = false,
		},
		options = {
			relativenumber = false,
		},
		search_dirs = { "~/Dev" },
	},
}

function M.name()
	return vim.g.nvim_profile or os.getenv("NVIM_PROFILE") or "personal"
end

local function load_local_overlay()
	local ok, overlay = pcall(require, "profile_local")
	if ok and type(overlay) == "table" then
		return overlay
	end
	return nil
end

local function load_local_dir_overlays()
	local dir = vim.fn.stdpath("config") .. "/lua/local"
	if vim.fn.isdirectory(dir) == 0 then
		return {}
	end

	local names = {}
	for _, path in ipairs(vim.fn.globpath(dir, "*.lua", false, true)) do
		table.insert(names, vim.fn.fnamemodify(path, ":t:r"))
	end
	table.sort(names)

	local overlays = {}
	for _, name in ipairs(names) do
		local ok, overlay = pcall(require, "local." .. name)
		if ok and type(overlay) == "table" then
			table.insert(overlays, overlay)
		end
	end
	return overlays
end

function M.get()
	if M._cache then
		return M._cache
	end

	local profile = vim.tbl_deep_extend("force", vim.deepcopy(defaults), profiles[M.name()] or {})

	local local_overlay = load_local_overlay()
	if local_overlay then
		profile = vim.tbl_deep_extend("force", profile, local_overlay)
	end

	for _, overlay in ipairs(load_local_dir_overlays()) do
		profile = vim.tbl_deep_extend("force", profile, overlay)
	end

	M._cache = profile
	return profile
end

function M.plugin_enabled(name)
	local p = M.get()
	if vim.tbl_contains(p.disabled_plugins, name) then
		return false
	end
	local v = p.plugins[name]
	if v == nil then
		return true
	end
	return v
end

function M.lsp_server_enabled(server)
	local v = M.get().lsp.servers[server]
	if v == nil then
		return true
	end
	return v
end

function M.format_enabled(ft)
	local v = M.get().format[ft]
	if v == nil then
		return true
	end
	return v
end

function M.extra(key)
	return M.get().extra[key] or {}
end

function M.apply_options()
	local p = M.get()
	for k, v in pairs(p.options) do
		vim.opt[k] = v
	end
	for k, v in pairs(p.globals) do
		vim.g[k] = v
	end
end

return M
