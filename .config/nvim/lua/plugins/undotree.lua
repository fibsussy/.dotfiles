return {
  "mbbill/undotree",
  event = "BufRead",
  init = function()
    local map = require("core.mappings").map
    map("n", "<leader>u", "<cmd>UndotreeToggle<CR>", { desc = "UndotreeToggle" })
  end,
}
