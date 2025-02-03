return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      current_line_blame = false,
    },
    init = function()
      local M = require "core.mappings"
      local gs = require('gitsigns')

      M.map("n", "]c", function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.nav_hunk("next") end)
          return '<Ignore>'
        end,
        { desc = "Gitsigns next hunk", expr = true, silent = true, noremap = true }
      )

      M.map("n", "[c", function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.nav_hunk("prev") end)
          return '<Ignore>'
        end,
        { desc = "Gitsigns previous hunk", expr = true, silent = true, noremap = true }
      )

      M.map({"n", "v"}, "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", {
        desc = "Gitsigns stage hunk", silent = true, noremap = true
      })

      M.map({"n", "v"}, "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", {
        desc = "Gitsigns reset hunk", silent = true, noremap = true
      })

      M.map("n", "<leader>hS", gs.stage_buffer, {
        desc = "Gitsigns stage buffer", silent = true, noremap = true
      })

      M.map("n", "<leader>ha", gs.stage_hunk, {
        desc = "Gitsigns stage hunk", silent = true, noremap = true
      })

      M.map("n", "<leader>hR", gs.reset_buffer, {
        desc = "Gitsigns reset buffer", silent = true, noremap = true
      })

      M.map("n", "<leader>hp", gs.preview_hunk, {
        desc = "Gitsigns preview hunk", silent = true, noremap = true
      })

      M.map("n", "<leader>hb", function() gs.blame_line{full=true} end, {
        desc = "Gitsigns blame line", silent = true, noremap = true
      })

      M.map("n", "<leader>tB", gs.toggle_current_line_blame, {
        desc = "Gitsigns toggle blame", silent = true, noremap = true
      })

      M.map("n", "<leader>hd", gs.diffthis, {
        desc = "Gitsigns diff this", silent = true, noremap = true
      })

      M.map("n", "<leader>hD", function() gs.diffthis('~') end, {
        desc = "Gitsigns diff HEAD", silent = true, noremap = true
      })

      M.map({"o", "x"}, "ih", "<cmd>Gitsigns select_hunk<CR>", {
        desc = "Gitsigns select hunk", silent = true, noremap = true
      })
    end
  }
}
