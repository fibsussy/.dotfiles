return {
  "tpope/vim-fugitive",
  lazy = false,
  init = function()
    vim.keymap.set("n", "<leader>gs", "<cmd>G<CR>", { desc = "Git Status" })
    vim.keymap.set("n", "<leader>gl", "<cmd>Git log --all --decorate --oneline --graph<CR>", { desc = "Git Log" })
    vim.keymap.set("n", "<leader>gL", "<cmd>GlLog<CR>", { desc = "Git Advanced Log" })
    vim.keymap.set("n", "<leader>gf", "<cmd>Git fetch<CR>", { desc = "Git Fetch" })
    vim.keymap.set("n", "<leader>gp", "<cmd>Git pull<CR>", { desc = "Git Pull" })
    vim.keymap.set("n", "<leader>gP", "<cmd>Git push<CR>", { desc = "Git Push" })
    vim.keymap.set("n", "<leader>gir", "<cmd>Git rebase -i --root<CR>", { desc = "Git Rebase Interactive (root)" })
    vim.keymap.set("n", "<leader>git", "<cmd>Git rebase -i HEAD~10<CR>", { desc = "Git Rebase Interactive (last 10 commits)" })
    vim.keymap.set("n", "<leader>gc", "<cmd>Telescope git_branches<CR>", { desc = "Git Checkout" })
  end,
}
