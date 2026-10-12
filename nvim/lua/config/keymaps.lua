-- Toggle Spell Check
vim.keymap.set("n", "<leader>sp", "<cmd>setlocal spell!<cr>", { silent = true, desc = "Toggle spell check" })

-- Yank
vim.keymap.set("v", "<leader>y", '"+y', { silent = true, desc = "Yank to system clipboard" })
vim.keymap.set("v", "<leader>x", '"+d', { silent = true, desc = "Cut to system clipboard" })

-- Clear search
vim.keymap.set("n", "<leader>/", "<cmd>nohlsearch<cr>", { silent = true, desc = "Clear search highlight" })

-- Open Terminal
vim.keymap.set("n", "<leader>t", function()
	vim.cmd("belowright 15split | term")
end, { silent = true, desc = "Open terminal" })

-- Open Terminal in a new tab
vim.keymap.set("n", "<leader>T", function()
	vim.cmd("tabnew | term")
end, { silent = true, desc = "Open terminal (new tab)" })

-- Yank current file's directory to the system clipboard
vim.keymap.set("n", "yd", function()
	local dir = vim.fn.expand("%:p:h")
	vim.fn.setreg('"', dir)
	vim.fn.setreg("+", dir)
	vim.notify("Yanked directory: " .. dir)
end, { silent = true, desc = "Yank file directory" })

-- Terminal: exit insert mode with Escape
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { silent = true, desc = "Terminal: exit insert mode" })

-- Toggle jk
local toggle_jk = false
vim.keymap.set("n", "<leader>sj", function()
	if toggle_jk then
		vim.keymap.set("n", "j", "j", { remap = false, silent = true })
		vim.keymap.set("n", "k", "k", { remap = false, silent = true })
		toggle_jk = false
		vim.notify("Switched to normal j/k")
	else
		vim.keymap.set("n", "j", "gj", { remap = false, silent = true })
		vim.keymap.set("n", "k", "gk", { remap = false, silent = true })
		toggle_jk = true
		vim.notify("Switched to gj/gk")
	end
end, { silent = true, desc = "Toggle j/k and gj/gk" })

-- Theme selector
vim.keymap.set("n", "<leader>st", function()
	require("config.theme_picker").pick()
end, { silent = true, desc = "Theme: pick" })

-- Navigate between splits with Ctrl-hjkl
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true, desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true, desc = "Move to below split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true, desc = "Move to above split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true, desc = "Move to right split" })

-- Keep selection after indent/unindent
vim.keymap.set("v", "<", "<gv", { silent = true, desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { silent = true, desc = "Indent right and reselect" })

-- Center cursor after search navigation
vim.keymap.set("n", "n", "nzzzv", { silent = true, desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { silent = true, desc = "Prev search result (centered)" })

-- Replace strings
vim.keymap.set("n", "<leader>sr", ":%s//gc<Left><Left><Left>", { silent = false, desc = "Search & replace (global)" })
vim.keymap.set(
	"n",
	"<leader>sq",
	":cdo %s//gc | update<Left><left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>",
	{ silent = false, desc = "Search & replace (quickfix)" }
)

-- Toggle Virtual Edit (Jump to any column)
vim.keymap.set("n", "<leader>sv", function()
	if vim.o.virtualedit == "all" then
		vim.o.virtualedit = ""
		print("Virtualedit OFF")
	else
		vim.o.virtualedit = "all"
		print("Virtualedit ON")
	end
end, { silent = true, desc = "Toggle virtual edit" })

-- Floating window helper
local function open_float(buf, title)
	local width = math.floor(vim.o.columns * 0.7)
	local height = math.floor(vim.o.lines * 0.7)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = title and (" " .. title .. " ") or nil,
		title_pos = "center",
	})

	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true, desc = "Close float" })
end

-- Scratch buffer (throwaway, no save)
vim.keymap.set("n", "<leader>sb", function()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "markdown"
	open_float(buf, "Scratch")
end, { silent = true, desc = "Open scratch buffer (float)" })

-- Cheatsheet helpers
local function open_cheatsheet(path, title, seed)
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
	if vim.fn.filereadable(path) == 0 then
		vim.fn.writefile(seed, path)
	end
	local buf = vim.fn.bufadd(path)
	vim.fn.bufload(buf)
	vim.bo[buf].filetype = "markdown"
	open_float(buf, title)
end

local function project_root()
	local cwd = vim.fn.getcwd()
	local git = vim.fs.find(".git", { upward = true, path = cwd })[1]
	if git then
		return vim.fs.dirname(git)
	end
	return cwd
end

-- Global cheatsheet (~/.local/share/nvim/cheatsheet.md)
vim.keymap.set("n", "<leader>sm", function()
	open_cheatsheet(
		vim.fn.stdpath("data") .. "/cheatsheet.md",
		"Cheatsheet",
		{ "# My Cheatsheet", "", "Edit freely. `:w` to save. `q` to close." }
	)
end, { silent = true, desc = "Open global cheatsheet (float)" })

-- Project cheatsheet (~/.local/share/nvim/cheatsheets/<sanitized-path>.md)
vim.keymap.set("n", "<leader>sM", function()
	local root = project_root()
	local sanitized = root:gsub("/", "%%")
	local path = vim.fn.stdpath("data") .. "/cheatsheets/" .. sanitized .. ".md"
	open_cheatsheet(
		path,
		"Project: " .. vim.fn.fnamemodify(root, ":t"),
		{ "# " .. vim.fn.fnamemodify(root, ":t"), "", "Project-scoped notes. `:w` to save. `q` to close." }
	)
end, { silent = true, desc = "Open project cheatsheet (float)" })
