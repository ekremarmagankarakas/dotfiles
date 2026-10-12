----------------------------------------------------------------------
-- AI keymaps
--
-- These exist unconditionally -- independent of whether copilot.lua or
-- CopilotChat.nvim are enabled via profile -- and always dispatch through
-- config.ai.get_active_provider(), so a registered custom AI provider
-- (see lua/config/ai.lua) gets full keymap coverage regardless of which
-- backend plugins happen to be installed. There is no default provider:
-- if none is active, dispatch() says so instead of erroring.
----------------------------------------------------------------------

local function dispatch(group, action, ...)
	local provider = require("config.ai").get_active_provider()
	if not provider then
		vim.notify("ai: no AI provider is active", vim.log.levels.WARN)
		return
	end
	return provider[group][action](...)
end

local map = vim.keymap.set

-- Inline suggestions
map("n", "<leader>act", function()
	dispatch("suggest", "toggle")
end, { silent = true, desc = "AI: toggle suggestions" })

map("n", "<leader>ace", function()
	dispatch("suggest", "enable")
end, { silent = true, desc = "AI: enable suggestions" })

map("n", "<leader>acd", function()
	dispatch("suggest", "disable")
end, { silent = true, desc = "AI: disable suggestions" })

map("n", "<leader>aca", function()
	dispatch("suggest", "toggle_auto_trigger")
end, { silent = true, desc = "AI: toggle auto-trigger" })

-- Chat
map("n", "<leader>aac", function()
	dispatch("chat", "toggle")
end, { silent = true, desc = "AI: toggle chat" })

map("v", "<leader>aaf", function()
	dispatch("chat", "fix")
end, { silent = true, desc = "AI: fix selection" })

map("v", "<leader>aar", function()
	dispatch("chat", "refactor")
end, { silent = true, desc = "AI: refactor selection" })

map("v", "<leader>aae", function()
	dispatch("chat", "explain")
end, { silent = true, desc = "AI: explain selection" })

map("v", "<leader>aat", function()
	dispatch("chat", "tests")
end, { silent = true, desc = "AI: generate tests for selection" })
