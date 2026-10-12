----------------------------------------------------------------------
-- AI keymaps
--
-- These exist unconditionally -- independent of whether copilot.lua or
-- CopilotChat.nvim are enabled via profile -- and always dispatch through
-- config.ai.get_active_provider(), so a registered custom AI provider
-- (see lua/config/ai.lua) gets full keymap coverage regardless of which
-- backend plugins happen to be installed. If the active provider's backing
-- plugin isn't loaded, its own functions notify instead of erroring.
----------------------------------------------------------------------

local function provider()
	return require("config.ai").get_active_provider()
end

local map = vim.keymap.set

-- Inline suggestions
map("n", "<leader>act", function()
	provider().suggest.toggle()
end, { silent = true, desc = "AI: toggle suggestions" })

map("n", "<leader>ace", function()
	provider().suggest.enable()
end, { silent = true, desc = "AI: enable suggestions" })

map("n", "<leader>acd", function()
	provider().suggest.disable()
end, { silent = true, desc = "AI: disable suggestions" })

map("n", "<leader>aca", function()
	provider().suggest.toggle_auto_trigger()
end, { silent = true, desc = "AI: toggle auto-trigger" })

-- Chat
map("n", "<leader>aac", function()
	provider().chat.toggle()
end, { silent = true, desc = "AI: toggle chat" })

map("v", "<leader>aaf", function()
	provider().chat.fix()
end, { silent = true, desc = "AI: fix selection" })

map("v", "<leader>aar", function()
	provider().chat.refactor()
end, { silent = true, desc = "AI: refactor selection" })

map("v", "<leader>aae", function()
	provider().chat.explain()
end, { silent = true, desc = "AI: explain selection" })

map("v", "<leader>aat", function()
	provider().chat.tests()
end, { silent = true, desc = "AI: generate tests for selection" })
