return {
  {
    'lewis6991/gitsigns.nvim',
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      current_line_blame = false,
      numhl = true,
    },
    keys = {
      { "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() require('gitsigns').nav_hunk("next") end)
        return "<Ignore>"
      end, desc = "Gitsigns next hunk", expr = true, silent = true, noremap = true },
      { "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() require('gitsigns').nav_hunk("prev") end)
        return "<Ignore>"
      end, desc = "Gitsigns previous hunk", expr = true, silent = true, noremap = true },
      { "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", mode = { "n", "v" }, desc = "Gitsigns stage hunk", silent = true, noremap = true },
      { "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", mode = { "n", "v" }, desc = "Gitsigns reset hunk", silent = true, noremap = true },
      { "<leader>hS", function() require('gitsigns').stage_buffer() end, desc = "Gitsigns stage buffer", silent = true, noremap = true },
      { "<leader>ha", function() require('gitsigns').stage_hunk() end, desc = "Gitsigns stage hunk", silent = true, noremap = true },
      { "<leader>hR", function() require('gitsigns').reset_buffer() end, desc = "Gitsigns reset buffer", silent = true, noremap = true },
      { "<leader>hp", function() require('gitsigns').preview_hunk() end, desc = "Gitsigns preview hunk", silent = true, noremap = true },
      { "<leader>hb", function() require('gitsigns').blame_line { full = true } end, desc = "Gitsigns blame line", silent = true, noremap = true },
      { "<leader>tB", function() require('gitsigns').toggle_current_line_blame() end, desc = "Gitsigns toggle blame", silent = true, noremap = true },
      { "<leader>hd", function() require('gitsigns').diffthis() end, desc = "Gitsigns diff this", silent = true, noremap = true },
      { "<leader>hD", function() require('gitsigns').diffthis('~') end, desc = "Gitsigns diff HEAD", silent = true, noremap = true },
      { "ih", "<cmd>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "Gitsigns select hunk", silent = true, noremap = true },
    },
  }
}
