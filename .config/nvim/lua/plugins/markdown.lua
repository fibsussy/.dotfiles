return {

  {
    "iamcco/markdown-preview.nvim",
    cmd = {
      "MarkdownPreviewToggle",
      "MarkdownPreview",
      "MarkdownPreviewStop",
    },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  {
    'MeanderingProgrammer/markdown.nvim',
    main = "render-markdown",
    name = 'render-markdown',
    ft = { "markdown" },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
  },

  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local notes_path = vim.fn.expand("~/Notes")
      if vim.fn.isdirectory(notes_path) == 0 then
        return
      end
      require("obsidian").setup({
        workspaces = {
          {
            name = "Notes",
            path = notes_path,
          },
        },
      })
    end,
  },



}
