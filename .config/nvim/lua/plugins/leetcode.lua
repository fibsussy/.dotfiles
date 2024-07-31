local leet_arg = "leetcode.nvim"
return {
  "kawre/leetcode.nvim",
  lazy = leet_arg ~= vim.fn.argv()[1],
  opts = {
    arg = leet_arg,
    lang = "rust",
    description = {
      position = "right",
    },
  },
  build = ":TSUpdate html",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- "rcarriga/nvim-notify",
    "nvim-tree/nvim-web-devicons",
  },
  init = function()
    local map = require("mappings").map
    map("n", "<leader>lr", "<cmd> Leet run <CR>", { desc = ":Leet run" })
    map("n", "<leader>ls", "<cmd> Leet submit <CR>", { desc = ":Leet submit" })
    map("n", "<leader>lc", "<cmd> Leet close <CR>", { desc = ":Leet close" })
    map("n", "<leader>lm", "<cmd> Leet menu <CR>", { desc = ":Leet menu" })
    map("n", "<leader>lo", "<cmd> Leet open <CR>", { desc = ":Leet open" })
    map("n", "<leader>ld", "<cmd> Leet desc <CR>", { desc = ":Leet desc" })
    map("n", "<leader>le", "<cmd> Leet exit <CR>", { desc = ":Leet exit" })
  end,
}
