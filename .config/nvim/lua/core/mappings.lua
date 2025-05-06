vim.keymap.set("n", "<C-s>", "<cmd>w<cr>", { desc = "Save Buffer", silent = true })
vim.keymap.set("n", "<C-S-a>", "ggVG", { desc = "Select All Buffer", silent = true })
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


-- Folding
vim.keymap.set('n', 'zR', function() vim.cmd('set foldlevel=999') end, { desc = 'Folds: Open all folds' })
vim.keymap.set('n', 'zM', function() vim.cmd('set foldlevel=0') end, { desc = 'Folds: Close all folds' })
vim.keymap.set('n', 'za', 'za', { desc = 'Folds: Toggle current fold' })
vim.keymap.set('n', 'zA', 'zA', { desc = 'Folds: Toggle current fold recursively' })
vim.keymap.set('n', 'zc', 'zc', { desc = 'Folds: Close current fold' })
vim.keymap.set('n', 'zC', 'zC', { desc = 'Folds: Close current fold recursively' })
vim.keymap.set('n', 'zo', 'zo', { desc = 'Folds: Open current fold' })
vim.keymap.set('n', 'zO', 'zO', { desc = 'Folds: Open current fold recursively' })
