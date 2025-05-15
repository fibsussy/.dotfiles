local leet_arg = "leetcode.nvim"

return {
  "kawre/leetcode.nvim",
  lazy = leet_arg ~= vim.fn.argv()[1],
  opts = {
    arg = leet_arg,
    lang = "rust",
    description = { position = "right" },
  },
  build = ":TSUpdate html",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    vim.keymap.set("n", "<leader>lr", "<cmd>Leet run<CR>", { desc = ":Leet run" })
    vim.keymap.set("n", "<leader>ls", "<cmd>Leet submit<CR>", { desc = ":Leet submit" })
    vim.keymap.set("n", "<leader>lc", "<cmd>Leet close<CR>", { desc = ":Leet close" })
    vim.keymap.set("n", "<leader>lm", "<cmd>Leet menu<CR>", { desc = ":Leet menu" })
    vim.keymap.set("n", "<leader>lo", "<cmd>Leet open<CR>", { desc = ":Leet open" })
    vim.keymap.set("n", "<leader>ld", "<cmd>Leet desc<CR>", { desc = ":Leet desc" })
    vim.keymap.set("n", "<leader>le", "<cmd>Leet exit<CR>", { desc = ":Leet exit" })
  end,
}
