----------------------------------------------------------------------
-- VCS keymaps
--
-- These exist unconditionally -- independent of whether gitsigns.nvim,
-- diffview.nvim, or telescope.nvim are enabled -- and always dispatch
-- through config.vcs.get_active_provider(), so a registered custom VCS
-- provider (see lua/config/vcs.lua) gets full keymap coverage regardless
-- of which backend-UI plugins happen to be installed. If the active
-- provider's backing plugin isn't loaded, its own functions notify
-- instead of erroring (see with_module/with_command in vcs.lua).
----------------------------------------------------------------------

local function provider()
	return require("config.vcs").get_active_provider()
end

local map = vim.keymap.set

-- Hunk preview
map("n", "<leader>gp", function()
	provider().hunk.preview()
end, { silent = true, desc = "Git: preview hunk" })

map("n", "<leader>gP", function()
	provider().hunk.preview_inline()
end, { silent = true, desc = "Git: preview hunk inline" })

-- Hunk navigation
map("n", "]g", function()
	provider().hunk.next()
end, { silent = true, desc = "Git: next hunk" })

map("n", "[g", function()
	provider().hunk.prev()
end, { silent = true, desc = "Git: prev hunk" })

-- Stage / reset (normal + visual)
map("n", "<leader>gs", function()
	provider().hunk.stage()
end, { silent = true, desc = "Git: stage hunk" })

map("v", "<leader>gs", function()
	provider().hunk.stage({ vim.fn.line("."), vim.fn.line("v") })
end, { silent = true, desc = "Git: stage hunk (visual)" })

map("n", "<leader>gr", function()
	provider().hunk.reset()
end, { silent = true, desc = "Git: reset hunk" })

map("v", "<leader>gr", function()
	provider().hunk.reset({ vim.fn.line("."), vim.fn.line("v") })
end, { silent = true, desc = "Git: reset hunk (visual)" })

map("n", "<leader>gS", function()
	provider().hunk.stage_buffer()
end, { silent = true, desc = "Git: stage buffer" })

map("n", "<leader>gR", function()
	provider().hunk.reset_buffer()
end, { silent = true, desc = "Git: reset buffer" })

map("n", "<leader>gu", function()
	provider().hunk.undo_stage()
end, { silent = true, desc = "Git: undo stage hunk" })

-- Hunk text object (global -- no longer scoped to gitsigns' on_attach)
map({ "o", "x" }, "ih", function()
	provider().hunk.select()
end, { silent = true, desc = "Git: select hunk" })

-- Toggles
map("n", "<leader>gT", function()
	provider().hunk.toggle_signs()
end, { silent = true, desc = "Git: toggle signs" })

-- Blame
map("n", "<leader>gb", function()
	provider().blame.line_full()
end, { silent = true, desc = "Git: full commit description for line" })

map("n", "<leader>gB", function()
	provider().blame.buffer()
end, { silent = true, desc = "Git: full buffer blame" })

map("n", "<leader>gtb", function()
	provider().blame.toggle_line()
end, { silent = true, desc = "Git: toggle inline line blame" })

-- Diff
map("n", "<leader>gdo", function()
	provider().diff.open()
end, { silent = true, desc = "Open Diffview" })

map("n", "<leader>gdc", function()
	provider().diff.close()
end, { silent = true, desc = "Close Diffview" })

map("n", "<leader>gdh", function()
	provider().diff.history_all()
end, { silent = true, desc = "File History (all)" })

map("n", "<leader>gdf", function()
	provider().diff.history_file()
end, { silent = true, desc = "File History (current)" })

map("n", "<leader>gdt", function()
	provider().diff.toggle_files()
end, { silent = true, desc = "Toggle File Panel" })

-- Telescope-style pickers
map("n", "<leader>gtc", function()
	provider().pickers.commits()
end, { silent = true, desc = "VCS: commits (Telescope)" })

map("n", "<leader>gts", function()
	provider().pickers.status()
end, { silent = true, desc = "VCS: status (Telescope)" })

map("n", "<leader>gtB", function()
	provider().pickers.branches()
end, { silent = true, desc = "VCS: branches (Telescope)" })
