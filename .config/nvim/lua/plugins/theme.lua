local function set_custom_highlights()
  vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })

  local dark_gray = "#6b7273"
  vim.api.nvim_set_hl(0, "@comment", { fg = "#FF5E54" })
  vim.api.nvim_set_hl(0, "LspInlayHint", { fg = dark_gray, bg = "NONE" })

  vim.api.nvim_set_hl(0, "LineNr", { fg = dark_gray })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FFFFFF", bold = true })

  local async_color = "#FF1493" -- Hot pink
  local await_color = "#FF69B4" -- Deep pink

  vim.api.nvim_set_hl(0, "@lsp.typemod.function.async", { fg = async_color })
  vim.api.nvim_set_hl(0, "@lsp.typemod.method.async", { fg = async_color })
  vim.api.nvim_set_hl(0, "@lsp.typemod.function.call.async", { fg = async_color })
  vim.api.nvim_set_hl(0, "@lsp.typemod.method.call.async", { fg = async_color })
  vim.api.nvim_set_hl(0, "@keyword.coroutine", { fg = await_color })
end
set_custom_highlights()

vim.api.nvim_create_autocmd({ "ColorScheme" }, {
  callback = function()
    set_custom_highlights()
  end,
})


function _G.update_status_column()
  local line_number = vim.v.lnum
 local current_line = vim.fn.line('.')
  if line_number == current_line then
    return "%s%#CursorLineNr# " .. line_number .. "❯%#NONE# "
  end
  if vim.wo.relativenumber then
    local relative_number = line_number - current_line
    if relative_number < 0 then
      return "%#LineNr#%s" .. math.abs(relative_number) .. "k "
    elseif relative_number > 0 then
      return "%#LineNr#%s" .. math.abs(relative_number) .. "j "
    end
  else
    return "%#LineNr#%s:" .. line_number
  end
  return "%s" -- Fallback for empty lines
end
vim.o.statuscolumn = "%{%v:lua.update_status_column()%}"

vim.opt.nu = false
vim.opt.relativenumber = true


return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 999999,
  opts = { transparent_background = true },
  config = function()
    vim.cmd.colorscheme "catppuccin"
  end,
}
