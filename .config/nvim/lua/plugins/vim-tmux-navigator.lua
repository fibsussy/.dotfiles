return {
  "numToStr/Navigator.nvim",
  config = function()
    require("Navigator").setup()
    vim.keymap.set("n", "<C-Left>", require("Navigator").left, { desc = "Navigator: Window Left" })
    vim.keymap.set("n", "<C-Down>", require("Navigator").down, { desc = "Navigator: Window Down" })
    vim.keymap.set("n", "<C-Up>", require("Navigator").up, { desc = "Navigator: Window Up" })
    vim.keymap.set("n", "<C-Right>", require("Navigator").right, { desc = "Navigator: Window Right" })
  end,
  lazy = false,
}
