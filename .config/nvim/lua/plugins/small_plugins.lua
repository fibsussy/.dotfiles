return {
  "ray-x/go.nvim",
  "ray-x/guihua.lua",
  "tpope/vim-sleuth",
  { "lukas-reineke/indent-blankline.nvim", main = "ibl" },
  { "folke/twilight.nvim", ft = "markdown" },
  { "djoshea/vim-autoread", event = "BufRead" },
  {
    "johmsalas/text-case.nvim",
    event = "BufRead",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("textcase").setup()
      require("telescope").load_extension("textcase")
    end,
    init = function()
      vim.keymap.set("n", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })
      vim.keymap.set("v", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })
    end,
  },
}
