return {
  "ThePrimeagen/refactoring.nvim",
  keys = {
    { "<leader>re", function() require('refactoring').refactor('Extract Function') end, mode = "v", desc = "Extract function" },
    { "<leader>rf", function() require('refactoring').refactor('Extract Function To File') end, mode = "v", desc = "Extract function to file" },
    { "<leader>rv", function() require('refactoring').refactor('Extract Variable') end, mode = "v", desc = "Extract variable" },
    { "<leader>ri", function() require('refactoring').refactor('Inline Variable') end, mode = { "n", "v" }, desc = "Inline variable" },
    { "<leader>rb", function() require('refactoring').refactor('Extract Block') end, mode = "v", desc = "Extract block" },
    { "<leader>rbf", function() require('refactoring').refactor('Extract Block To File') end, mode = "v", desc = "Extract block to file" },
  },
  cmd = { "Refactor" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {},
}
