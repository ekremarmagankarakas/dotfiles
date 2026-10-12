----------------------------------------------------------------------
-- Telescope
----------------------------------------------------------------------
return {
	{
		"nvim-telescope/telescope-ui-select.nvim",
		cond = function()
			return require("profile").plugin_enabled("telescope-ui-select.nvim")
		end,
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
		cond = function()
			return require("profile").plugin_enabled("telescope-fzf-native.nvim")
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		branch = "master",
		cond = function()
			return require("profile").plugin_enabled("telescope.nvim")
		end,
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find: files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Find: live grep" },
			{
				"<leader>fF",
				function()
					require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") })
				end,
				desc = "Find: files (buffer dir)",
			},
			{
				"<leader>fG",
				function()
					require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h") })
				end,
				desc = "Find: live grep (buffer dir)",
			},
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find: buffers" },
			{ "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Find: oldfiles" },
			{ "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Find: word under cursor" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find: help tags" },
			{ "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Find: keymaps" },
			{ "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Find: commands" },
			{ "<leader>fC", "<cmd>Telescope command_history<cr>", desc = "Find: command history" },
			{ "<leader>fs", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find: in buffer" },
			{ "<leader>fm", "<cmd>Telescope marks<cr>", desc = "Find: marks" },
			{ "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "Find: jumplist" },
			{ "<leader>fr", "<cmd>Telescope registers<cr>", desc = "Find: registers" },
			{ "<leader>ft", "<cmd>Telescope treesitter<cr>", desc = "Find: treesitter" },
			{ "<leader>f/", "<cmd>Telescope search_history<cr>", desc = "Find: search history" },
			{ "<leader>fq", "<cmd>Telescope quickfix<cr>", desc = "Find: quickfix" },
			{ "<leader>fl", "<cmd>Telescope loclist<cr>", desc = "Find: loclist" },
			-- <leader>gtc/gts/gtB (VCS pickers) live in lua/config/vcs_keymaps.lua,
			-- not here -- they need to exist independent of whether telescope.nvim
			-- is enabled.
			{
				"<leader>fa",
				function()
					local dirs = require("profile").get().search_dirs

					local search_dirs = {}
					for _, dir in ipairs(dirs) do
						local expanded = vim.fn.expand(dir)
						if vim.fn.isdirectory(expanded) == 1 then
							table.insert(search_dirs, expanded)
						end
					end

					if #search_dirs == 0 then
						vim.notify("No search directories found", vim.log.levels.WARN)
						return
					end

					require("telescope.builtin").find_files({
						prompt_title = "Search in Selected Dirs",
						search_dirs = search_dirs,
						hidden = true,
						no_ignore = true,
						find_command = {
							"fd",
							"--type",
							"f",
							"--hidden",
							"--no-ignore",
							"--exclude",
							"node_modules",
							"--exclude",
							"venv",
							"--exclude",
							".venv",
							"--exclude",
							".git",
							"--exclude",
							"__pycache__",
						},
					})
				end,
				desc = "Find: selected dirs",
			},
		},
		-- A plain table here would be clobbered if another module's spec for
		-- this plugin also sets `opts` -- a function lets lazy.nvim merge
		-- every module's opts() result into one table before config() runs.
		opts = function()
			return {
				defaults = {
					sorting_strategy = "ascending",
					layout_strategy = "horizontal",
					layout_config = {
						prompt_position = "top",
						width = 0.95,
						height = 0.95,
						horizontal = {
							preview_width = 0.6,
						},
					},
					preview = { hide_on_startup = false },
					borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
				},
				extensions = {
					["ui-select"] = require("telescope.themes").get_dropdown(),
				},
			}
		end,

		config = function(_, opts)
			local telescope = require("telescope")

			telescope.setup(opts)

			telescope.load_extension("fzf")
			telescope.load_extension("ui-select")

			for _, ext in ipairs(require("profile").extra("telescope_extensions")) do
				pcall(telescope.load_extension, ext)
			end
		end,
	},
}
