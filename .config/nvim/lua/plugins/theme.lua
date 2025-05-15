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
  if not ( vim.wo.number or vim.wo.relativenumber ) then
    return "%s" -- do nothing
  end
  local line_number = vim.v.lnum
  local current_line = vim.fn.line('.')
  if line_number == current_line then
    if not vim.wo.number then
      line_number = 0
    end
    if vim.wo.relativenumber then
      return "%s%#CursorLineNr# " .. line_number .. "❯%#NONE# "
    else
      return "%s%#CursorLineNr# :" .. line_number .. "❯%#NONE# "
    end
  end
  if not vim.wo.relativenumber then
    return "%#LineNr#%s:" .. line_number
  end
  local relative_number = line_number - current_line
  if relative_number < 0 then
    return "%#LineNr#%s" .. math.abs(relative_number) .. "k "
  elseif relative_number > 0 then
    return "%#LineNr#%s" .. math.abs(relative_number) .. "j "
  end
end

vim.schedule(function()
  vim.o.statuscolumn = "%{%v:lua.update_status_column()%}"
end)

vim.o.number = true
vim.o.relativenumber = true

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  callback = function()
    if not vim.wo.relativenumber then
      vim.wo.statuscolumn = vim.wo.statuscolumn
    end
  end,
})

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 999999,
  opts = { transparent_background = true },
  config = function()
    vim.cmd.colorscheme "catppuccin"
  end,
}
