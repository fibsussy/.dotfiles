return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio"
    },
    init = function()
      local M = require "core.mappings"

      vim.fn.sign_define('DapBreakpoint', { text='🔴', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl='DapBreakpoint' })

      M.map("n", "<leader>dt", function() require('dapui').toggle() end, {
        desc = "DAP toggle UI",
      })
      M.map("n", "<leader>db", function() require('dap').toggle_breakpoint() end, {
        desc = "DAP toggle breakpoint",
      })
      M.map("n", "<leader>dc", function() require('dap').continue() end, {
        desc = "DAP start/continue",
      })
      M.map("n", "<leader>dr", function() require('dapui').open({reset = true}) end, {
        desc = "DAP reset session",
      })
      M.map("n", "<leader>ht", function() require('harpoon.ui').toggle_quick_menu() end, {
        desc = "Harpoon toggle menu",
      })
    end
  },
  'theHamsta/nvim-dap-virtual-text',
  'leoluz/nvim-dap-go',
}
