-- Numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Persistent undo
vim.opt.undofile = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- UI
vim.opt.mouse = "a"
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.showmode = false
vim.opt.scrolloff = 8
vim.opt.completeopt = "menu,menuone,noselect"

-- Timing
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Leaders
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Python
vim.g.python_recommended_style = 0

-- Pattern-matching engine limit (large :%s// patterns, treesitter-related regex fallback)
vim.opt.maxmempattern = 20000

-- Force the "files" ref storage format for git commands nvim shells out to
-- (gitsigns, diffview, fugitive-likes), independent of the user's git config
vim.env.GIT_DEFAULT_REF_FORMAT = "files"

-- Profile overrides (machine-local tweaks live in profile_local.lua / lua/local/*.lua)
require("profile").apply_options()
