lua << EOF
vim.g.notepad_disabled = {
  "lualine.nvim",
  "nvim-treesitter-context",
  "nvim-web-devicons",
  "mini.nvim",
  "neominimap.nvim",
  "indent-blankline.nvim",
  "todo-comments.nvim",
  "trouble.nvim",
  "noice.nvim",
  "nui.nvim",
  "fidget.nvim",
  "lspkind.nvim",
  "nvim-highlight-colors",
  "gitsigns.nvim",
  "vim-fugitive",
  "vim-flog",
  "gitlinker.nvim",
  "gist.nvim",
  "git-conflict.nvim",
  "snacks.nvim",
  "nvim-dap-ui",
  "nvim-dap-virtual-text",
  "nvim-dap-go",
  "go.nvim",
  "guihua.lua",
  "rustaceanvim",
  "crates.nvim",
  "mason.nvim",
  "mason-lspconfig.nvim",
  "nvim-lspconfig",
  "conform.nvim",
  "vim-autoread",
}
EOF
runtime init.lua
set laststatus=2
set cmdheight=1
set signcolumn=no
set foldcolumn=0
set nocursorline
set wrap
set linebreak
set title
set titlestring=Notes\ nvim
set iconstring=
autocmd BufEnter * set laststatus=2
lua << EOF
local function style()
  local function mix(c1, c2, t)
    local a = { (c1 >> 16) & 0xFF, (c1 >> 8) & 0xFF, c1 & 0xFF }
    local b = { (c2 >> 16) & 0xFF, (c2 >> 8) & 0xFF, c2 & 0xFF }
    local r = {}
    for i = 1, 3 do r[i] = math.floor(a[i] + (b[i] - a[i]) * t) end
    return (r[1] << 16) | (r[2] << 8) | r[3]
  end
  local base = vim.api.nvim_get_hl(0, { name = "Normal" })
  local bg = base.bg or 0
  local fg = base.fg or 0xE0DEF0
  vim.api.nvim_set_hl(0, "StatusLine", { fg = mix(bg, fg, 0.05), bg = "NONE" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = mix(bg, fg, 0.05), bg = "NONE" })
  vim.api.nvim_set_hl(0, "ModeMsg", { fg = mix(bg, fg, 0.05), bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "MsgArea", { fg = mix(bg, fg, 0.15), bg = "NONE" })
  vim.api.nvim_set_hl(0, "MsgSeparator", { fg = "NONE", bg = "NONE" })
end
local setup = function()
  style()
  vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "UIEnter" }, {
    pattern = "*",
    callback = style,
  })
  vim.defer_fn(style, 50)
  vim.defer_fn(style, 200)
end
setup()
EOF
