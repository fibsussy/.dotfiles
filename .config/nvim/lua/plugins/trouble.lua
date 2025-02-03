return {
  {
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    init = function()
      local M = require "core.mappings"

      -- Keybindings with descriptions
      M.map("n", "<leader>xx", "<cmd>TroubleToggle<cr>", {
        desc = "Trouble Toggle"
      })
      M.map("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", {
        desc = "Trouble workspace diagnostics"
      })
      M.map("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", {
        desc = "Trouble document diagnostics"
      })
      M.map("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", {
        desc = "Trouble loclist"
      })
      M.map("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", {
        desc = "Trouble quickfix"
      })
      M.map("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", {
        desc = "Trouble LSP references"
      })

      local signs = {
        Error = " ",
        Warning = " ",
        Hint = " ",
        Information = " "
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    end
  }
}
