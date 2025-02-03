return {
  { "williamboman/mason.nvim", opts = {}, },
  { "j-hui/fidget.nvim", opts = {} },
  { "hrsh7th/cmp-nvim-lsp", opts = {} },
  { "onsails/lspkind.nvim", opts = {} },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "clangd",
        "rust_analyzer",
        "pyright",
        "ts_ls",
        "gopls",
      }
    }
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "j-hui/fidget.nvim",
      "hrsh7th/cmp-nvim-lsp"
    },
    config = function()
      local M = require "core.mappings"
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local function on_attach(_, bufnr)
        local function lsp_map(mode, lhs, rhs, desc)
          M.map(mode, lhs, rhs, {
            buffer = bufnr,
            desc = "LSP: " .. desc,
          })
        end

        lsp_map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        lsp_map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        lsp_map("n", "gd", vim.lsp.buf.definition, "Goto definition")
        lsp_map("n", "<leader>gr", require("telescope.builtin").lsp_references, "Goto references")
        lsp_map("n", "gI", vim.lsp.buf.implementation, "Goto implementation")
        lsp_map("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")
        lsp_map("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, "Document symbols")
        lsp_map("n", "<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace symbols")
        lsp_map("n", "K", vim.lsp.buf.hover, "Hover documentation")
        lsp_map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
        lsp_map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
        lsp_map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
        lsp_map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
        lsp_map("n", "<leader>wl", function() 
          print(vim.inspect(vim.lsp.buf.list_workspace_folders())) 
        end, "List workspace folders")

        vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
          vim.lsp.buf.format()
        end, { desc = "LSP: Format current buffer" })
      end

      local servers = {
        "clangd",
        "rust_analyzer",
        "pyright",
        "ts_ls",
        "gopls",
      }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          on_attach = on_attach,
          capabilities = capabilities,
        }
      end

      lspconfig.lua_ls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "sh",
        callback = function()
          vim.lsp.start({
            name = "bash-language-server",
            cmd = { "bash-language-server", "start" },
          })
        end,
      })
    end
  }
}
