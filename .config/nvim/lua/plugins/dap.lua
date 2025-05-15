return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      { "<leader>dt", desc = "DAP toggle UI" },
      { "<leader>db", desc = "DAP toggle breakpoint" },
      { "<leader>dc", desc = "DAP start/continue" },
      { "<leader>dr", desc = "DAP reset session" },
    },
    cmd = { "DapContinue", "DapToggleBreakpoint" },
    config = function()
      vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })

      vim.keymap.set("n", "<leader>dt", function() require('dapui').toggle() end, { desc = "DAP toggle UI" })
      vim.keymap.set("n", "<leader>db", function() require('dap').toggle_breakpoint() end, { desc = "DAP toggle breakpoint" })
      vim.keymap.set("n", "<leader>dc", function() require('dap').continue() end, { desc = "DAP start/continue" })
      vim.keymap.set("n", "<leader>dr", function() require('dapui').open({ reset = true }) end, { desc = "DAP reset session" })
      vim.keymap.set("n", "<leader>ht", function() require('harpoon.ui').toggle_quick_menu() end, { desc = "Harpoon toggle menu" })
    end,
  },
  "theHamsta/nvim-dap-virtual-text",
  "leoluz/nvim-dap-go",
}
