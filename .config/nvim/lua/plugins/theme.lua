local function set_custom_highlights()
  vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })

  vim.api.nvim_set_hl(0, "LineNr", { fg = "#6b7273" })
  vim.api.nvim_set_hl(0, "Comment", { fg = "#FF0000" })
  vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })
  vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" })

  local async_color = "#FF1493" -- Hot pink
  local await_color = "#FF69B4" -- Deep pink

  vim.api.nvim_set_hl(0, "@lsp.typemod.function.async", { fg = async_color })
  vim.api.nvim_set_hl(0, "@lsp.typemod.method.async", { fg = async_color })
  vim.api.nvim_set_hl(0, "@lsp.typemod.function.call.async", { fg = async_color })
  vim.api.nvim_set_hl(0, "@lsp.typemod.method.call.async", { fg = async_color })
  vim.api.nvim_set_hl(0, "@keyword.coroutine", { fg = await_color })
end


vim.api.nvim_create_autocmd({ "ColorScheme", }, {
  callback = function()
    set_custom_highlights()
  end,
})

vim.o.statusline = "%f"

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 999999,
  opts = { transparent_background = true },
  config = function()
    vim.cmd.colorscheme "catppuccin"
  end,
}
