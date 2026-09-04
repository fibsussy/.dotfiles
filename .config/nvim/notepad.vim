runtime init.lua
lua local c = require("lazy.core.config"); local p = c.plugins["lualine.nvim"]; if p then require("lazy.core.handler").disable(p) end
set laststatus=0
set nocursorline
set wrap
set linebreak
set title
set titlestring=Notes\ nvim
set iconstring=
autocmd BufEnter * set laststatus=0
