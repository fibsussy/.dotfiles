
---@type ChadrcConfig
local M = {}

M.base46 = {
    theme = "catppuccin",
    transparency = true,
    hl_override = {
        LineNr = { fg = "#6b7273" },
        Comment = { fg = "#FF0000" },
        ["@comment"] = { link = "Comment" },
        LspInlayHint = { link = "Comment" },
    },
    statusline = {
        modules = {
            file = function ()
                return " %f "
            end
        },
    },
}


return M
