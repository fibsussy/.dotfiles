return {
  {
    "ThePrimeagen/vim-be-good",
    lazy = true,
    cmd = { "VimBeGood" },
  },
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
    },
    opts = {
      enabled = true,
      hint = true,
      disabled_keys = {
        ["<Up>"] = {},
        ["<Down>"] = {},
        ["<Left>"] = {},
        ["<Right>"] = {},
      },
      disable_mouse = false,
    },
  },
}
