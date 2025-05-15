local servers = {
  cssls = {},
  html = {},
  phpactor = {},
  tailwindcss = {},
  gopls = {},
  pyright = {},
  rust_analyzer = {},
  clangd = {},
  omnisharp = {},
  jdtls = {},
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false
        },
        telemetry = { enable = false },
      }
    }
  },
  tsserver = {
    settings = {
      completions = {
        completeFunctionCalls = true
      }
    }
  },
}

local lsp_buf = vim.lsp.buf
vim.keymap.set("n", "grn", lsp_buf.rename, { desc = "LSP: Rename" })
vim.keymap.set("n", "gra", lsp_buf.code_action, { desc = "LSP: Code action" })
vim.keymap.set("n", "gd", lsp_buf.definition, { desc = "LSP: Goto definition" })
vim.keymap.set("n", "grr", lsp_buf.references, { desc = "LSP: Find references" })
vim.keymap.set("n", "<leader>gr", require("telescope.builtin").lsp_references, { desc = "LSP: Telescope references" })
vim.keymap.set("n", "gri", lsp_buf.implementation, { desc = "LSP: Go to implementation" })
vim.keymap.set("n", "<leader>D", lsp_buf.type_definition, { desc = "LSP: Type definition" })
vim.keymap.set("n", "gO", lsp_buf.document_symbol, { desc = "LSP: Document symbols" })
vim.keymap.set("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, { desc = "LSP: Document symbols" })
vim.keymap.set("n", "<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols,
  { desc = "LSP: Workspace symbols" })
vim.keymap.set("n", "K", lsp_buf.hover, { desc = "LSP: Hover documentation" })
vim.keymap.set("n", "<C-k>", lsp_buf.signature_help, { desc = "LSP: Signature help" })
vim.keymap.set("n", "gD", lsp_buf.declaration, { desc = "LSP: Goto declaration" })
vim.keymap.set("n", "<leader>ca", lsp_buf.code_action, { desc = "LSP: Code actions (verbose)" })

-- Workspace folders
vim.keymap.set("n", "<leader>wa", lsp_buf.add_workspace_folder, { desc = "LSP: Add workspace folder" })
vim.keymap.set("n", "<leader>wr", lsp_buf.remove_workspace_folder, { desc = "LSP: Remove workspace folder" })
vim.keymap.set("n", "<leader>wl", function() print(vim.inspect(lsp_buf.list_workspace_folders())) end,
  { desc = "LSP: List workspace folders" })

-- Formatting
vim.api.nvim_buf_create_user_command(0, "Format", function() lsp_buf.format() end,
  { desc = "LSP: Format current buffer" })
vim.keymap.set("n", "<leader>fm", function()
  require("conform").format()
  vim.cmd "w"
  print "Formatted and Saved"
end, { desc = "Format and Save File" })


vim.diagnostic.config({
  virtual_lines = { current_line = true },
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
for server, config in pairs(servers) do
  local server_config = vim.tbl_deep_extend("keep", {
    capabilities = capabilities,
  }, config)
  vim.lsp.config[server] = server_config
  vim.lsp.enable({server})
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "sh",
  callback = function()
    vim.lsp.config.bashls = {}
    vim.lsp.enable({'bashls'})
  end,
})


return {
  { "j-hui/fidget.nvim", event={"LspAttach"} },
  { "hrsh7th/cmp-nvim-lsp" },
  { "onsails/lspkind.nvim" },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      timeout_ms = 10000,
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettier" },
        json = { "prettier" },
        html = { "prettier" },
        rust = { "rustfmt" },
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {'williamboman/mason.nvim'},
      {
        'williamboman/mason-lspconfig.nvim',
        opts = {
          automatic_enable = true
        }
      },
    },
    event = { "BufReadPre", "BufNewFile" },
  },

}
