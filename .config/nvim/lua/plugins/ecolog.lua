return {
  {
    't3ntxcl3s/ecolog.nvim',
    keys = {
      -- { '<leader>ge', '<cmd>EcologGoto<cr>', desc = 'Go to env file' },
      -- { '<leader>ep', '<cmd>EcologPeek<cr>', desc = 'Ecolog peek variable' },
      -- { '<leader>es', '<cmd>EcologSelect<cr>', desc = 'Switch env file' },
    },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      integrations = {
        nvim_cmp = true,
      },
      shelter = {
        configuration = {
          partial_mode = {
            show_start = 4,
            show_end = 4,
            min_mask = 20,
          },
          mask_char = "*",
          mask_length = nil,
          skip_comments = false,
        },
        modules = {
          cmp = true,
          peek = true,
          files = true,
          telescope = true,
          telescope_previewer = true,
          fzf = true,
          fzf_previewer = true,
          snacks_previewer = true,
          snacks = true,
        }
      },
      types = true,
      path = vim.fn.getcwd(),
      provider_patterns = true, -- true by default, when false will not check provider patterns
    },
  },
}
