return {
	"mfussenegger/nvim-dap",
	cond = function()
		return require("profile").plugin_enabled("nvim-dap")
	end,
	dependencies = {
		-- UI and Core Helpers
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",

		-- Language Specific Helpers
		"mfussenegger/nvim-dap-python", -- Python
		"leoluz/nvim-dap-go", -- Go
		"mxsdev/nvim-dap-vscode-js", -- JS/TS
		"julianolf/nvim-dap-lldb", -- C/C++/Rust
	},
	keys = {
		-- Core run
		{ "<leader>dc", desc = "DAP Prepare and Continue" },
		-- Stepping
		{
			"<leader>dn",
			function()
				require("dap").step_over()
			end,
			desc = "DAP Step Over",
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "DAP Step Into",
		},
		{
			"<leader>do",
			function()
				require("dap").step_out()
			end,
			desc = "DAP Step Out",
		},
		{
			"<leader>dC",
			function()
				require("dap").run_to_cursor()
			end,
			desc = "DAP Run to Cursor",
		},
		-- Breakpoints
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "DAP Toggle Breakpoint",
		},
		{
			"<leader>dB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "DAP Conditional Breakpoint",
		},
		{
			"<leader>dl",
			function()
				require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end,
			desc = "DAP Logpoint",
		},
		-- Inspection & UI
		{
			"<leader>dh",
			function()
				require("dap.ui.widgets").hover()
			end,
			desc = "DAP Hover",
		},
		{
			"<leader>dh",
			function()
				require("dap.ui.widgets").hover()
			end,
			mode = "v",
			desc = "DAP Hover Selection",
		},
		{
			"<leader>dr",
			function()
				require("dap").repl.toggle()
			end,
			desc = "DAP Toggle REPL",
		},
		{
			"<leader>dq",
			function()
				require("dap").terminate()
			end,
			desc = "DAP Terminate",
		},
		{
			"<leader>du",
			function()
				require("dapui").toggle()
			end,
			desc = "DAP UI Toggle",
		},
		-- Python Specific
		{ "<leader>ds", desc = "Debug nearest Python test" },
		{ "<leader>df", desc = "Debug Python test class" },
		{ "<leader>de", desc = "Debug selection", mode = "v" },
		-- Toggles
		{
			"<leader>dtj",
			function()
				_G.DAP_JUST_MY_CODE = not _G.DAP_JUST_MY_CODE
				vim.notify("DAP justMyCode = " .. tostring(_G.DAP_JUST_MY_CODE))
			end,
			desc = "Toggle justMyCode",
		},
		{
			"<leader>dtv",
			function()
				_G.DAP_USE_VSCODE_LAUNCH = not _G.DAP_USE_VSCODE_LAUNCH
				vim.notify("DAP VSCode launch.json = " .. tostring(_G.DAP_USE_VSCODE_LAUNCH))
			end,
			desc = "Toggle VS Code launch.json",
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		----------------------------------------------------------------------
		-- Global Toggles
		----------------------------------------------------------------------
		_G.DAP_JUST_MY_CODE = false
		_G.DAP_USE_VSCODE_LAUNCH = false

		----------------------------------------------------------------------
		-- Prepare Phase (shared by ALL entry points)
		----------------------------------------------------------------------
		local function dap_prepare()
			if not _G.DAP_USE_VSCODE_LAUNCH then
				return
			end

			if vim.fn.filereadable(".vscode/launch.json") == 1 then
				require("dap.ext.vscode").load_launchjs(nil, {
					lldb = { "c", "cpp", "rust" },
					["pwa-node"] = { "javascript", "typescript", "typescriptreact" },
					python = { "python" },
				})
			end
		end

		----------------------------------------------------------------------
		-- Language Specific Setup
		----------------------------------------------------------------------
		-- Python (Mason path)
		local debugpy_path = vim.fn.stdpath("data")
			.. "/mason/packages/debugpy/venv/"
			.. (vim.uv.os_uname().sysname == "Windows_NT" and "Scripts/python.exe" or "bin/python")

		require("dap-python").setup(debugpy_path, {
			justMyCode = function()
				return _G.DAP_JUST_MY_CODE
			end,
		})

		dap.configurations.python = {
			{
				type = "python",
				request = "launch",
				name = "Launch file",
				program = "${file}",
				console = "integratedTerminal",
				cwd = "${workspaceFolder}",
				justMyCode = function()
					return _G.DAP_JUST_MY_CODE
				end,
			},
		}

		-- Go
		require("dap-go").setup()

		-- C/C++/Rust (via CodeLLDB)
		require("dap-lldb").setup()

		-- JS/TS (Node)
		require("dap-vscode-js").setup({
			adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal" },
		})
		for _, language in ipairs({ "typescript", "javascript", "typescriptreact" }) do
			dap.configurations[language] = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch Current File",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
			}
		end

		----------------------------------------------------------------------
		-- UI and virtual text
		----------------------------------------------------------------------
		dapui.setup()
		require("nvim-dap-virtual-text").setup()

		dap.listeners.after.event_initialized["dapui_open"] = function()
			dapui.open()
		end

		dap.listeners.before.event_terminated["dapui_close"] = function()
			dapui.close()
		end

		dap.listeners.before.event_exited["dapui_close"] = function()
			dapui.close()
		end

		----------------------------------------------------------------------
		-- Keymaps that need dap_prepare()
		----------------------------------------------------------------------
		local map = vim.keymap.set
		local dappy = require("dap-python")

		map("n", "<leader>dc", function()
			dap_prepare()
			dap.continue()
		end, { desc = "DAP Prepare and Continue" })

		map("n", "<leader>ds", function()
			dap_prepare()
			dappy.test_method()
		end, { desc = "Debug nearest Python test" })

		map("n", "<leader>df", function()
			dap_prepare()
			dappy.test_class()
		end, { desc = "Debug Python test class" })

		map("v", "<leader>de", function()
			dap_prepare()
			dappy.debug_selection()
		end, { desc = "Debug selection" })
	end,
}
