return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    config = function()
      vim.g.rustaceanvim = {
        -- Plugin configuration
        tools = {
        },
        -- LSP configuration
        server = {
          on_attach = function(client, bufnr)
            -- you can also put keymaps in here
          end,
          default_settings = {
            -- rust-analyzer language server configuration
            ["rust-analyzer"] = {
            },
          },
        },
        -- DAP configuration
        dap = {
        },
      }

      -- Auto-start LSP for .ron files
      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*.ron",
        callback = function()
          local config = require('rustaceanvim.config.internal')
          local auto_attach = config.server.auto_attach
          if type(auto_attach) == 'function' then
            local bufnr = vim.api.nvim_get_current_buf()
            auto_attach = auto_attach(bufnr)
          end
          if auto_attach then
            -- Try to start LSP, but don't fail if it doesn't work
            pcall(require('rustaceanvim.lsp').start)
          end
        end,
      })
    end,
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup()
    end,
  },
}
