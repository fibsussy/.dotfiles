vim.api.nvim_set_hl(0, "LineNr", { fg = "#6b7273" })
vim.api.nvim_set_hl(0, "Comment", { fg = "#FF0000" })
vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })
vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" })

vim.o.statusline = "%f"

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "catppuccin",
  callback = function()
    -- Apply transparency
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })

    local async_color = "#FF69B4" -- Hot pink 
    local await_color = "#FF1493" -- Deep pink 

    vim.api.nvim_set_hl(0, "@function.async", { fg = async_color })
    vim.api.nvim_set_hl(0, "@call.async", { fg = async_color })
    vim.api.nvim_set_hl(0, "@keyword.coroutine", { fg = await_color })
  end,
})

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 999999,
  opts = {
    transparent_background = true,
  },
  config = function()
    vim.cmd.colorscheme "catppuccin"
  end,
}
