return {
  "tpope/vim-fugitive",
  cmd = { "G", "Git", "Gvdiffsplit", "GlLog" },
  keys = {
    { "<leader>gs", "<cmd>G<CR>", desc = "Git Status" },
    { "<leader>gl", "<cmd>Git log --all --decorate --oneline --graph<CR>", desc = "Git Log" },
    { "<leader>gL", "<cmd>GlLog<CR>", desc = "Git Advanced Log" },
    { "<leader>gf", "<cmd>Git fetch<CR>", desc = "Git Fetch" },
    { "<leader>gp", "<cmd>Git pull<CR>", desc = "Git Pull" },
    { "<leader>gP", "<cmd>Git push<CR>", desc = "Git Push" },
    { "<leader>gir", "<cmd>Git rebase -i --root<CR>", desc = "Git Rebase Interactive (root)" },
    { "<leader>git", "<cmd>Git rebase -i HEAD~10<CR>", desc = "Git Rebase Interactive (last 10 commits)" },
    { "<leader>gc", "<cmd>Telescope git_branches<CR>", desc = "Git Checkout" },
  },
}
