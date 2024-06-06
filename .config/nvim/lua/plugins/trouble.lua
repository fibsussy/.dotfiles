return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  init = function()
    local map = require("mappings").map
    local t = require("trouble")
    map("n", "<leader>xx", t.toggle, { desc = "Toggle Trouble" })
    map("n", "<leader>xw", function() t.toggle("workspace_diagnostics") end, { desc = "Toggle Workspace Diagnostics" })
    map("n", "<leader>xd", function() t.toggle("document_diagnostics") end, { desc = "Toggle Document Diagnostics" })
    map("n", "<leader>xq", function() t.toggle("quickfix") end, { desc = "Toggle Quickfix" })
    map("n", "<leader>xl", function() t.toggle("loclist") end, { desc = "Toggle Location List" })
    map("n", "gR", function() t.toggle("lsp_references") end, { desc = "LSP References" })
  end,
}
