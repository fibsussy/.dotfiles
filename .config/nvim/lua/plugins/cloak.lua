return {
  {
    "laytan/cloak.nvim",
    lazy = false,
    keys = {
      {
        "<leader>ct",
        "<cmd>CloakToggle<cr>",
        { desc = "Cloak Toggle" },
      },
    },
    cmd = { "CloakToggle", },
    opts = {
      enabled = true,
      cloak_character = "*",
      highlight_group = "Comment",
      cloak_length = nil,
      try_all_patterns = true,
      cloak_telescope = true,
      cloak_on_leave = false,
      patterns = {
        {
          file_pattern = ".env*",
          cloak_pattern = "=.+",
          replace = nil,
        },
      },
    },
  },
}
