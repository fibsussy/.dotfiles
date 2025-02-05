local servers = {
  { "pyright", {} },
  { "lua_ls", {}, mason = true },
  { "rust_analyzer", {} },
  { "clangd", {} },
  { "omnisharp", {} },
  { "jdtls", {} },
  { "ts_ls", { settings = { completions = { completeFunctionCalls = true } } } },
  { "cssls", {} },
  { "html", {} },
  { "phpactor", {} },
  { "tailwindcss", {} },
  { "gopls", {} },
}

local function grab_server_names()
  local mason_servers = {}
  for _, server in ipairs(servers) do
    if server.mason then table.insert(mason_servers, server[1]) end
  end
  return mason_servers
end


return {
  { "preservim/tagbar", lazy = false },
  { "williamboman/mason.nvim", opts = {} },
  { "j-hui/fidget.nvim", opts = {} },
  { "hrsh7th/cmp-nvim-lsp", opts = {} },
  { "onsails/lspkind.nvim", opts = {} },
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
    init = function()
      local map = require("core.mappings").map
      local nomap = require("core.mappings").nomap
      nomap("n", "<leader>fm")
      map("n", "<leader>fm", function()
        require("conform").format()
        vim.cmd "w"
        print "Formatted and Saved"
      end, { desc = "Format and Save File" })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = { ensure_installed = grab_server_names(), automatic_installation = false },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "j-hui/fidget.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local M = require "core.mappings"
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local function on_attach(_, bufnr)
        local function lsp_map(mode, lhs, rhs, desc)
          M.map(mode, lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc })
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
        lsp_map("n", "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, "List workspace folders")
        vim.api.nvim_buf_create_user_command(bufnr, "Format", function() vim.lsp.buf.format() end, { desc = "LSP: Format current buffer" })
      end

      for _, server in ipairs(servers) do
        lspconfig[server[1]].setup {
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
          vim.lsp.start({ name = "bash-language-server", cmd = { "bash-language-server", "start" } })
        end,
      })
    end,
  },
}
