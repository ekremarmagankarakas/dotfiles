return {
	----------------------------------------------------------------------
	-- Copilot
	--
	-- Keymaps that dispatch through config.ai (<leader>act/ace/acd/aca) live
	-- in lua/config/ai_keymaps.lua, not here -- they need to exist
	-- independent of whether this plugin is enabled. The ghost-text
	-- accept/next/prev/dismiss keys below stay plugin-local since they're
	-- copilot.lua's own tightly-coupled insert-mode UI.
	----------------------------------------------------------------------
	{
		"zbirenbaum/copilot.lua",
		cond = function()
			return require("profile").plugin_enabled("copilot.lua")
		end,
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = {
				auto_trigger = false,
				keymap = {
					accept = "<M-y>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			panel = { enabled = false },
		},
	},

	----------------------------------------------------------------------
	-- Copilot Chat (for selection prompts)
	--
	-- Keymaps that dispatch through config.ai (<leader>aac/aaf/aar/aae/aat)
	-- live in lua/config/ai_keymaps.lua. The chat-buffer-local mappings
	-- below stay here since they're CopilotChat's own tightly-coupled UI,
	-- not part of the AI abstraction.
	----------------------------------------------------------------------
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		cond = function()
			return require("profile").plugin_enabled("CopilotChat.nvim")
		end,
		dependencies = {
			"zbirenbaum/copilot.lua",
			"nvim-lua/plenary.nvim",
		},

		-- Builds the fast tokenizer helper if you have make + rust.
		build = "make tiktoken",

		opts = {
			-- UI preferences
			window = {
				layout = "vertical",
				width = 0.3,
			},

			-- Remap chat buffer actions
			mappings = {
				accept_diff = {
					normal = "<leader>aaa",
					insert = "<leader>aaa",
				},
				show_diff = {
					normal = "<leader>aad",
				},
				yank_diff = {
					normal = "<leader>aay",
				},
			},
		},

		-- CopilotChat's real module name ("CopilotChat") doesn't match
		-- lazy.nvim's inferred default (lowercased plugin name), so it
		-- needs an explicit config() to call setup() on the right module.
		config = function(_, opts)
			require("CopilotChat").setup(opts)
		end,
	},
}
