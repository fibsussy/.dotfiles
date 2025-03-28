return {
  "laytan/cloak.nvim",
  event = "VeryLazy",
  ft = { "sh", ".env" },
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
  init = function()
    vim.keymap.set("n", "<leader>ct", ":CloakToggle<CR>", { desc = "Cloak Toggle" })
  end,
}
