return {
  "numToStr/Navigator.nvim",
  cmd = {
    "NavigatorLeft",
    "NavigatorRight",
    "NavigatorUp",
    "NavigatorDown",
    "NavigatorPrevious",
  },
  keys = {
    { "<C-Left>", "<cmd>NavigatorLeft<cr>", desc = "Navigator: Window Left" },
    { "<C-Down>", "<cmd>NavigatorDown<cr>", desc = "Navigator: Window Down" },
    { "<C-Up>", "<cmd>NavigatorUp<cr>", desc = "Navigator: Window Up" },
    { "<C-Right>", "<cmd>NavigatorRight<cr>", desc = "Navigator: Window Right" },
  },
  opts = {},
}
