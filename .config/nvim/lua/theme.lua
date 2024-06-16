local function parse_theme()
  local path = os.getenv("HOME") .. "/.config/kitty/theme.conf"
  local file = io.open(path, "r")
  if not file then
    error("Unable to open the file: " .. path)
    return {}
  end
  local colors = {}
  for line in file:lines() do
    local key, value = line:match("^(%S+)%s+(#%x+)$")
    if key and value then
      colors[key] = value
    end
  end
  file:close()
  return {
    base00 = colors.background or "#FF0000",
    base01 = colors.selection_background or "#FF0000",
    base02 = colors.selection_background or "#FF0000",
    base03 = colors.color0 or "#FF0000",
    base04 = colors.foreground or "#FF0000",
    base05 = colors.foreground or "#FF0000",
    base06 = colors.cursor_text_color or "#FF0000",
    base07 = colors.cursor or "#FF0000",
    base08 = colors.color1 or "#FF0000",
    base09 = colors.color3 or "#FF0000",
    base0A = colors.color2 or "#FF0000",
    base0B = colors.color4 or "#FF0000",
    base0C = colors.color6 or "#FF0000",
    base0D = colors.color5 or "#FF0000",
    base0E = colors.color13 or "#FF0000",
    base0F = colors.color14 or "#FF0000",
  }
end

local M = {
  theme = parse_theme()
}


function M.update_theme()
  M.theme = parse_theme()
  require("chadrc").ui.changed_themes.ashes.base_16 = M.theme
  require("base46").load_all_highlights()
  print("reloaded theme")
end

return M
