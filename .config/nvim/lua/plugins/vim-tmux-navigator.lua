return {
  {
    "numToStr/Navigator.nvim",
    cmd = {
      "NavigatorLeft",
      "NavigatorRight",
      "NavigatorUp",
      "NavigatorDown",
      "NavigatorPrevious",
    },
    keys = {
      { "<M-Left>", "<cmd>NavigatorLeft<cr>", desc = "Navigator: Window Left" },
      { "<M-Down>", "<cmd>NavigatorDown<cr>", desc = "Navigator: Window Down" },
      { "<M-Up>", "<cmd>NavigatorUp<cr>", desc = "Navigator: Window Up" },
      { "<M-Right>", "<cmd>NavigatorRight<cr>", desc = "Navigator: Window Right" },
      { "<C-Left>", "<cmd>NavigatorLeft<cr>", desc = "Navigator: Window Left" },
      { "<C-Down>", "<cmd>NavigatorDown<cr>", desc = "Navigator: Window Down" },
      { "<C-Up>", "<cmd>NavigatorUp<cr>", desc = "Navigator: Window Up" },
      { "<C-Right>", "<cmd>NavigatorRight<cr>", desc = "Navigator: Window Right" },
    },
    opts = {},
  },
}
