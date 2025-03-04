return {
  {
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { desc = "Trouble Toggle" })
      vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { desc = "Trouble workspace diagnostics" })
      vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", { desc = "Trouble document diagnostics" })
      vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", { desc = "Trouble loclist" })
      vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { desc = "Trouble quickfix" })
      vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", { desc = "Trouble LSP references" })

      local signs = {
        Error = " ",
        Warning = " ",
        Hint = " ",
        Information = " ",
      }

      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    end,
  },
}
