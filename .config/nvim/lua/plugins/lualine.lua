
local function get_tmux_session_name()

  local handle = io.popen("tmux display-message -p '#S' 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()

    return result:gsub("%s+$", "")
  end
  return ""
end


return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        icons_enabled = true,
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = {
          {
            require("noice").api.statusline.mode.get,
            cond = require("noice").api.statusline.mode.has,
            color = { fg = "#ff9e64" },
          },
          {
            function()
              return " " .. get_tmux_session_name()
            end,
            color = { fg = "#7aa2f7" },
          },
        },
        lualine_y = { 'encoding', 'fileformat', 'filetype' },
        lualine_z = { 'progress', 'location' },
      },
    },
  },
}
