return {
  "mbbill/undotree",
  event = "BufRead",
  init = function()
    vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR>", { desc = "UndotreeToggle" })
  end,
}
