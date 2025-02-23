local o = vim.o
local opt = vim.opt

vim.g.mapleader = ' '
vim.g.localmapleader = ' '

o.clipboard = 'unnamedplus'

o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.smartindent = true

o.wrap = false

o.swapfile = false
o.backup = false
o.undodir = os.getenv "HOME" .. "/.vim/undodir"
o.undofile = true

o.termguicolors = true

o.scrolloff = 8
o.signcolumn = "no"
opt.isfname:append "@-@"

opt.fillchars = { eob = " " }

o.updatetime = 1

o.colorcolumn = "0"

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

