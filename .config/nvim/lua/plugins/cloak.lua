return {
  "laytan/cloak.nvim",
  ft = { "sh", ".env" },
  opts = {
    enabled = true,
    cloak_character = "*",
    highlight_group = "Comment",
    cloak_length = nil,
    try_all_patterns = true,
    patterns = {
      {
        file_pattern = ".env*",
        cloak_pattern = "=.+",
        replace = nil,
      },
    },
  },
  config = function()
    vim.keymap.set("n", "<leader>ct", ":CloakToggle<CR>", { desc = "Cloak Toggle" })
  end,
}
