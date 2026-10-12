local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Machine-local rtp_paths (gitignored plugin_dirs/modules outside lua/local)
-- need to be on the runtimepath before anything requires/imports them.
require("profile").apply_rtp()

require("config")

require("profile").load_modules()

vim.api.nvim_create_user_command("Profile", function()
	vim.notify("Active profile: " .. require("profile").name(), vim.log.levels.INFO)
end, { desc = "Show active nvim profile" })

local plugin_spec = { { import = "plugins" } }
for _, dir in ipairs(require("profile").get().plugin_dirs) do
	table.insert(plugin_spec, { import = dir })
end

require("lazy").setup({
	spec = plugin_spec,
	checker = { enabled = false },
	-- lazy.nvim resets 'runtimepath' on startup; without this it would drop
	-- the rtp_paths we just prepended above.
	performance = {
		rtp = {
			paths = require("profile").get().rtp_paths,
		},
	},
})

local theme = require("config.theme_picker").load()
local ok, _ = pcall(vim.cmd.colorscheme, theme)
if not ok then
	vim.notify("Colorscheme '" .. theme .. "' not found, falling back to default", vim.log.levels.WARN)
end
