vim.keymap.set("n", "<C-s>", "<cmd>w<cr>", { desc = "Save Buffer", silent = true })
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select All Buffer", silent = true })
vim.keymap.set("n", "<C-c>", "<cmd>%y+<cr>", { desc = "Copy All Buffer", silent = true })
vim.keymap.set("n", "<leader>q", "<cmd>bd!<cr>", { desc = "Close Buffer", silent = true })
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and restore cursor position", silent = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half a page and recenter", silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half a page and recenter", silent = true })
vim.keymap.set("n", "n", "nzzzv", { desc = "Find next and recenter", silent = true })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Find previous and recenter", silent = true })
vim.keymap.set("n", "*", "*zz", { desc = "Search word under cursor and recenter", silent = true })

vim.keymap.set("n", "<leader>;", function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  if line_content:sub(-1) == ";" then
    line_content = line_content:sub(1, -2)
  else
    line_content = line_content .. ";"
  end
  vim.api.nvim_buf_set_lines(0, line - 1, line, false, { line_content })
end, { desc = "Toggle semicolon at end of line", silent = true })

-- Visual mode mappings
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move visual selection down", silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move visual selection up", silent = true })

