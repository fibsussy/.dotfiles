return {
  {
    "johmsalas/text-case.nvim",
    lazy = false,
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("textcase").setup {}
      require("telescope").load_extension "textcase"
    end,
    init = function()
      local map = require("mappings").map
      map("n", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })
      map("v", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })
    end,
  },
}
