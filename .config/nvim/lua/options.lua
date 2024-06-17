require "nvchad.options"

local o = vim.o

o.relativenumber = true
o.number = true

o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true

o.wrap = false

o.swapfile = false
o.backup = false
o.undodir = os.getenv "HOME" .. "/.vim/undodir"
o.undofile = true

o.termguicolors = true

o.scrolloff = 8
o.signcolumn = "yes"
vim.opt.isfname:append "@-@"

o.updatetime = 1

o.colorcolumn = "0"
