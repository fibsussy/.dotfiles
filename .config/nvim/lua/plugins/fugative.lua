return {
  "tpope/vim-fugitive",
  lazy = false,
  init = function()
    local map = require("mappings").map
    map("n", "<leader>gs", "<cmd> G <CR>", { desc = "Git Status" })
    map("n", "<leader>gl", "<cmd> Git log --all --decorate --oneline --graph <CR>", { desc = "Git Log" })
    map("n", "<leader>gL", "<cmd> GlLog <CR>", { desc = "Git Advanced Log" })
    map("n", "<leader>gf", "<cmd> Git fetch <CR>", { desc = "Git Fetch" })
    map("n", "<leader>gp", "<cmd> Git pull <CR>", { desc = "Git Pull" })
    map("n", "<leader>gP", "<cmd> Git push <CR>", { desc = "Git Push" })
    map("n", "<leader>gir", "<cmd> Git rebase -i --root <CR>", { desc = "Git Rebase Interactive (root)" })
    map("n", "<leader>git", "<cmd> Git rebase -i HEAD~10 <CR>", { desc = "Git Rebase Interactive (last 10 commits)" })
    map("n", "<leader>gc", "<cmd> Telescope git_branches <CR>", { desc = "Git Checkout" })

  end,
}
