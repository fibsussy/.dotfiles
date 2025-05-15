
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
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
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
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = {
          {
            function()
              local ok, noice = pcall(require, "noice")
              if ok then
                return noice.api.statusline.mode.get()
              end
              return ""
            end,
            cond = function()
              local ok, noice = pcall(require, "noice")
              if ok then
                return noice.api.statusline.mode.has()
              end
              return false
            end,
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
