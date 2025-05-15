return {

  {
    {
      "linrongbin16/gitlinker.nvim",
      cmd = "GitLink",
      opts = {},
      keys = {
        { "<leader>gy", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Yank git link" },
        { "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open git link" },
      },
    },
  },


  {
    "Rawnly/gist.nvim",
    dependencies = {
      -- `GistsList` opens the selected gist in a terminal buffer,
      -- nvim-unception uses neovim remote rpc functionality to open the gist in an actual buffer
      -- and prevents neovim buffer inception
      {
        "samjwill/nvim-unception",
        event = "VeryLazy",
        init = function() vim.g.unception_block_while_host_edits = true end
      },
    },
    cmd = { "GistCreate", "GistCreateFromFile", "GistsList" },
    opts = {
      private = true, 
      clipboard = "+",
      split_direction = "vertical",
      gh_cmd = "gh",
      list = {
        mappings = {
          next_file = "<C-n>",
          prev_file = "<C-p>"
        },
      },
    },

  },
}
