return {
  "numToStr/Navigator.nvim",
  config = function()
    require('Navigator').setup()
  end,
  lazy = false,
  init = function()
    local map = require("core.mappings").map
    local nomap = require("core.mappings").nomap
    local nav = require "Navigator"

    nomap("n", "<C-h>")
    nomap("n", "<C-l>")
    nomap("n", "<C-j>")
    nomap("n", "<C-k>")

    map("n", "<C-Left>", nav.left, { desc = "Navigator: Window Left" })
    map("n", "<C-Down>", nav.down, { desc = "Navigator: Window Down" })
    map("n", "<C-Up>", nav.up, { desc = "Navigator: Window Up" })
    map("n", "<C-Right>", nav.right, { desc = "Navigator: Window Right" })
  end,
}
