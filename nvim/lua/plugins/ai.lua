local copilot_auto_trigger = false

return {
	----------------------------------------------------------------------
	-- Copilot
	----------------------------------------------------------------------
	{
		"zbirenbaum/copilot.lua",
		cond = function()
			return require("profile").plugin_enabled("copilot.lua")
		end,
		cmd = "Copilot",
		event = "InsertEnter",
		keys = {
			{ "<leader>act", "<cmd>Copilot toggle<cr>", silent = true, desc = "Copilot: toggle" },
			{ "<leader>acd", "<cmd>Copilot disable<cr>", silent = true, desc = "Copilot: disable" },
			{ "<leader>ace", "<cmd>Copilot enable<cr>", silent = true, desc = "Copilot: enable" },
			{
				"<leader>aca",
				function()
					copilot_auto_trigger = not copilot_auto_trigger
					require("copilot.suggestion").toggle_auto_trigger()
					vim.notify("Copilot auto-trigger: " .. (copilot_auto_trigger and "ON" or "OFF"))
				end,
				silent = true,
				desc = "Copilot: toggle auto-trigger",
			},
		},
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

		config = function(_, opts)
			local chat = require("CopilotChat")
			chat.setup(opts)

			-- Visual selection hotkeys (send selection, get a response in chat)
			-- Uses the built-in #selection resource so you do not need a selection API.
			vim.keymap.set("v", "<leader>aaf", function()
				chat.ask("#selection /Fix", { prompt = "Fix selection" })
			end, { desc = "CopilotChat: Fix selection" })

			vim.keymap.set("v", "<leader>aar", function()
				chat.ask("#selection /Optimize", { prompt = "Refactor selection" })
			end, { desc = "CopilotChat: Refactor selection" })

			vim.keymap.set("v", "<leader>aae", function()
				chat.ask("#selection /Explain", { prompt = "Explain selection" })
			end, { desc = "CopilotChat: Explain selection" })

			vim.keymap.set("v", "<leader>aat", function()
				chat.ask("#selection /Tests", { prompt = "Generate tests for selection" })
			end, { desc = "CopilotChat: Tests for selection" })

			-- open/toggle chat quickly
			vim.keymap.set("n", "<leader>aac", "<cmd>CopilotChatToggle<cr>", { desc = "CopilotChat: Toggle" })
		end,
	},
}
