local servers = {
  { "pyright", {} },
  { "lua_ls", {}, mason = true },
  { "rust_analyzer", {} },
  { "clangd", {} },
  { "omnisharp", {} },
  { "jdtls", {} },
  { "tsserver", { settings = { completions = { completeFunctionCalls = true } } } },
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

local function setup_lsp_keybindings()
  -- Enhanced LSP keymaps with new 0.11 defaults
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename" })
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code action" })
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Goto definition" })
  vim.keymap.set("n", "grn", vim.lsp.buf.rename, { desc = "LSP: Rename symbol" }) -- New default
  vim.keymap.set("n", "grr", vim.lsp.buf.references, { desc = "LSP: Find references" }) -- New default
  vim.keymap.set("n", "<leader>gr", require("telescope.builtin").lsp_references, { desc = "LSP: Goto references" })
  vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "LSP: Goto implementation" })
  vim.keymap.set("n", "gri", vim.lsp.buf.implementation, { desc = "LSP: Go to implementation" }) -- New default
  vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "LSP: Type definition" })
  vim.keymap.set("n", "gO", vim.lsp.buf.document_symbol, { desc = "LSP: Document symbols" }) -- New default
  vim.keymap.set("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, { desc = "LSP: Document symbols" })
  vim.keymap.set("n", "<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols,
  { desc = "LSP: Workspace symbols" })
  vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover documentation" })
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "LSP: Signature help" })
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: Goto declaration" })
  vim.keymap.set("n", "gra", vim.lsp.buf.code_action, { desc = "LSP: Code actions" }) -- New default

  -- Workspace folders
  vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "LSP: Add workspace folder" })
  vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "LSP: Remove workspace folder" })
  vim.keymap.set("n", "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
  { desc = "LSP: List workspace folders" })

  -- Formatting
  vim.api.nvim_buf_create_user_command(0, "Format", function() vim.lsp.buf.format() end,
  { desc = "LSP: Format current buffer" })
  vim.keymap.set("n", "<leader>fm", function()
    require("conform").format()
    vim.cmd "w"
    print "Formatted and Saved"
  end, { desc = "Format and Save File" })
end

local function setup_lsp_servers()
  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  -- Enable LSP completion by default
  vim.lsp.completion.enable()

  -- Configure diagnostics (virtual text now disabled by default)
  vim.diagnostic.config({
    virtual_text = {
      prefix = "●", -- Changed from virtual_text = true to use new format
      spacing = 2,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })

  -- Set up LSP servers using new 0.11 API
  for _, server in ipairs(servers) do
    local config = {
      capabilities = capabilities,
      settings = server[2].settings or {},
    }

    -- Special case for LuaLS
    if server[1] == "lua_ls" then
      config.settings = {
        Lua = {
          runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
          diagnostics = { globals = { "vim" } },
          workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
          telemetry = { enable = false },
        }
      }
    end

    -- Register and enable the server
    vim.lsp.config[server[1]] = config
    vim.lsp.enable({ server[1] })
  end

  -- Special case for bash (filetype autocmd)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "sh",
    callback = function()
      vim.lsp.start({ name = "bash-language-server", cmd = { "bash-language-server", "start" } })
    end,
  })
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
      setup_lsp_keybindings()
      setup_lsp_servers()
    end,
  },
}
