
---@type ChadrcConfig
local M = {}

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

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
