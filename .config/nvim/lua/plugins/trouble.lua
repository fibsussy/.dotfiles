return {
  "folke/trouble.nvim",
 dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "BufRead",
  init = function()
    local map = require("mappings").map
    local nomap = require("mappings").nomap
    local t = require("trouble")
    map("n", "<leader>xx", function() t.toggle("diagnostics") end, { desc = "Diagnostics (Trouble)" })
    map("n", "<leader>xX", function() t.toggle("diagnostics", { filter = { buf = 0 } }) end, { desc = "Buffer Diagnostics (Trouble)" })
    map("n", "<leader>cs", function() t.toggle("symbols", { focus = false }) end, { desc = "Symbols (Trouble)" })
    map("n", "<leader>cl", function() t.toggle("lsp", { focus = false, win = { position = "right" } }) end, { desc = "LSP Definitions / references / ... (Trouble)" })
    map("n", "<leader>xL", function() t.toggle("loclist") end, { desc = "Location List (Trouble)" })
    map("n", "<leader>xQ", function() t.toggle("qflist") end, { desc = "Quickfix List (Trouble)" })
  end,
}
