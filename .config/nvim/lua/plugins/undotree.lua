return {
  "mbbill/undotree",
  event = "BufRead",
  init = function()
    local map = require("mappings").map
    map("n", "<leader>u", "<cmd>UndotreeToggle<CR>", { desc = "UndotreeToggle" })
  end,
}
