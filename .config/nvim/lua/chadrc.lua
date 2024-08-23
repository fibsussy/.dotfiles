M = {}

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

local theme = require("theme")
vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })
vim.api.nvim_set_hl(0, "LspInlayHint", { fg = theme.theme.base03 })

M.ui = {
    theme = "aquarium",
    changed_themes = { ashes = { base_16 = theme.theme } },
    transparency = true,
    hl_override = {
        LineNr = { fg = "#6b7273" },
        Comment = { fg = "#FF0000" },
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
