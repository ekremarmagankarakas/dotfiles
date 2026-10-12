return {
	----------------------------------------------------------------------
	-- Install Themes
	----------------------------------------------------------------------
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		priority = 1000,
		cond = function()
			return require("profile").plugin_enabled("catppuccin")
		end,
	},
	{
		"projekt0n/github-nvim-theme",
		name = "github-theme",
		lazy = true,
		priority = 1000,
		cond = function()
			return require("profile").plugin_enabled("github-theme")
		end,
	},
	{
		"Mofiqul/vscode.nvim",
		lazy = true,
		priority = 1000,
		cond = function()
			return require("profile").plugin_enabled("vscode.nvim")
		end,
	},
	-- { "Mofiqul/dracula.nvim", lazy = true, priority = 1000 },
	-- { "folke/tokyonight.nvim", lazy = true, priority = 1000 },
	-- { "Mofiqul/adwaita.nvim", lazy = true, priority = 1000 },
	-- { "rose-pine/neovim", lazy = true, priority = 1000 },

	----------------------------------------------------------------------
	-- Indent Blankline
	----------------------------------------------------------------------
	{
		"lukas-reineke/indent-blankline.nvim",
		cond = function()
			return require("profile").plugin_enabled("indent-blankline.nvim")
		end,
		main = "ibl",
		opts = {
			scope = {
				enabled = true,
				show_start = true,
				show_end = false,
			},
		},
	},

	----------------------------------------------------------------------
	-- Lualine
	----------------------------------------------------------------------
	{
		"nvim-lualine/lualine.nvim",
		cond = function()
			return require("profile").plugin_enabled("lualine.nvim")
		end,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = "auto",
				globalstatus = true,
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		},
	},
}
