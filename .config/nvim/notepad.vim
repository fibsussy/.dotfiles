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
set laststatus=0
set cmdheight=0
set signcolumn=no
set foldcolumn=0
set nocursorline
set wrap
set linebreak
set title
set titlestring=Notes\ nvim
set iconstring=
set scrolloff=2
set shortmess=aoOtTWcCF
silent! set shortmess+=W
set noshowcmd
set noshowmode
