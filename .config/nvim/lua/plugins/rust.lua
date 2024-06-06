return {
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    dependencies = "neovim/nvim-lspconfig",
    opts = {
      server = {
        on_attach = require("nvchad.configs.lspconfig").on_attach,
        capabilities = require("nvchad.configs.lspconfig").capabilities,
      },
      tools = {
        inlay_hints = {
          parameter_hints_prefix = "    ",
          other_hints_prefix = "    ",
          right_align = false,
          right_align_padding = 0,
          highlight = "LspInlayHint",
        },
      },
    },
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup()
    end,
  },
}
