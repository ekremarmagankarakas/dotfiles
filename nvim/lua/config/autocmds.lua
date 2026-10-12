----------------------------------------------------------------------
-- Disable built-in treesitter highlighter for markdown (nvim 0.12 regression)
----------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown" },
	callback = function(args)
		pcall(vim.treesitter.stop, args.buf)
	end,
})

----------------------------------------------------------------------
-- Swallow nil-node range crash from nvim-treesitter master query predicates
-- on nvim 0.12 (TSNode API drift). Affects LSP hover popups + conceal_line.
----------------------------------------------------------------------
do
	local orig = vim.treesitter.get_node_text
	vim.treesitter.get_node_text = function(...)
		local ok, result = pcall(orig, ...)
		if ok then
			return result
		end
		return ""
	end
end

----------------------------------------------------------------------
-- Markdown to PDF
----------------------------------------------------------------------
vim.api.nvim_create_user_command("MarkdownToPdf", function()
	local current_file = vim.fn.expand("%:p")
	local output_file = vim.fn.fnamemodify(current_file, ":r") .. ".pdf"
	vim.fn.system({
		"pandoc",
		current_file,
		"-o",
		output_file,
		"--pdf-engine=xelatex",
		"-V", "geometry:margin=1in",
	})
	vim.notify("Converted " .. current_file .. " to " .. output_file)
end, { desc = "Convert current Markdown file to PDF" })

vim.keymap.set("n", "<leader>ms", ":MarkdownToPdf<CR>", { desc = "Convert Markdown to Pdf" })

----------------------------------------------------------------------
-- C/C++ indentation: use cindent instead of treesitter (unreliable for C++)
----------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp" },
	callback = function()
		vim.schedule(function()
			vim.opt_local.indentexpr = ""
			vim.opt_local.cindent = true
			vim.opt_local.shiftwidth = 2
			vim.opt_local.tabstop = 2
			vim.opt_local.softtabstop = 2
		end)
	end,
})

----------------------------------------------------------------------
-- Trim Trailing Whitespace
----------------------------------------------------------------------
local trim_ws_group = vim.api.nvim_create_augroup("TrimTrailingWhitespace", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = trim_ws_group,
	desc = "Trim trailing whitespace",
	callback = function(args)
		if not require("profile").get().trim_trailing_whitespace then
			return
		end

		local bufnr = args.buf
		if vim.bo[bufnr].buftype ~= "" then
			return
		end

		-- Keep intentional trailing spaces (e.g. Markdown hard line breaks)
		local ft = vim.bo[bufnr].filetype
		if ft == "markdown" then
			return
		end

		local view = vim.fn.winsaveview()
		vim.cmd([[silent! %s/\s\+$//e]])
		vim.fn.winrestview(view)
	end,
})
