M = {}

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })
vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" })

M.ui = {
    theme = "catppuccin",
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
