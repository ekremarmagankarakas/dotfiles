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

	-- Gates the BufWritePre trim-trailing-whitespace autocmd in autocmds.lua.
	-- Kept outside `options` since it isn't a real vim.opt key.
	trim_trailing_whitespace = true,

	-- Extra module names to require() once config/options/keymaps are loaded.
	-- Lets gitignored machine-local files (e.g. lua/local/*.lua) do more than
	-- just return an overlay table -- they can be full setup modules.
	modules = {},

	-- Extra lazy.nvim spec `import` targets (module names resolvable on the
	-- runtimepath), merged into init.lua's lazy.setup({ spec = ... }) next to
	-- { import = "plugins" }. Lets gitignored plugin specs load the same way
	-- the tracked ones do.
	plugin_dirs = {},

	-- Extra directories prepended to 'runtimepath' so gitignored modules and
	-- plugin_dirs living outside lua/local (e.g. a separate untracked repo)
	-- are requireable/importable at all.
	rtp_paths = {},

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
		-- Extra fns(capabilities) -> capabilities, composed over the default
		-- cmp_nvim_lsp capabilities before any server is configured.
		lsp_update_capabilities = {},
		-- Extra fns(capabilities) run once after all built-in servers are set
		-- up, so other (possibly gitignored) modules can register additional
		-- LSP servers via vim.lsp.config/vim.lsp.enable.
		lsp_extra_setup = {},
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

local function load_local_overlay()
	local ok, overlay = pcall(require, "profile_local")
	if ok and type(overlay) == "table" then
		return overlay
	end
	return nil
end

function M.name()
	if vim.g.nvim_profile then
		return vim.g.nvim_profile
	end

	local env = os.getenv("NVIM_PROFILE")
	if env then
		return env
	end

	-- profile_local.lua can pick the active profile itself, e.g.
	-- `return { profile = "minimal", ... }`
	local overlay = load_local_overlay()
	if overlay and overlay.profile then
		return overlay.profile
	end

	return "personal"
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

-- Prepend profile.rtp_paths to 'runtimepath'. Call this before anything
-- tries to require() a module or lazy-import a spec living in one of them.
function M.apply_rtp()
	for _, path in ipairs(M.get().rtp_paths) do
		vim.opt.rtp:prepend(vim.fn.expand(path))
	end
end

-- require() every module in profile.modules, tolerating a missing/broken one
-- so a machine-local typo doesn't take the whole config down.
function M.load_modules()
	for _, name in ipairs(M.get().modules) do
		local ok, err = pcall(require, name)
		if not ok then
			vim.notify("profile: failed to load module '" .. name .. "': " .. tostring(err), vim.log.levels.WARN)
		end
	end
end

return M
