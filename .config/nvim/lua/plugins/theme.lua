
vim.api.nvim_set_hl(0, "LineNr", { fg = "#6b7273" })
vim.api.nvim_set_hl(0, "Comment", { fg = "#FF0000" })
vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })
vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" })

vim.o.statusline = "%f" 

vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })


return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opt = {
    transparent_background = true,
  },
  setup = function()
    vim.cmd("colorscheme catppuccin-mocha") 
  end,
}
