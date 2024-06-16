require "nvchad.mappings"

local M = {}

M.mappings = {}

function M.nomap(mode, lhs)
  table.insert(M.mappings, { action = "nomap", mode = mode, lhs = lhs })
end

function M.map(mode, lhs, rhs, opts)
  table.insert(M.mappings, { action = "map", mode = mode, lhs = lhs, rhs = rhs, opts = opts })
end

function M.init()
  for _, m in ipairs(M.mappings) do
    local status, err
    if m.action == "nomap" then
      status, err = pcall(vim.keymap.del, m.mode, m.lhs)
    elseif m.action == "map" then
      status, err = pcall(vim.keymap.set, m.mode, m.lhs, m.rhs, m.opts)
    end
    if not status then
      error(string.format("Error setting keymap: action=%s mode=%s lhs=%s rhs=%s opts=%s error=%s",
        m.action, m.mode, m.lhs, m.rhs or "nil", vim.inspect(m.opts), err))
    end
  end
end

M.nomap("n", "<C-n>")
M.nomap("n", "<leader>e")
M.nomap("n", "<leader>gt")
M.map("n", "<C-r>", require("theme").update_theme, { desc = "Reload" })
M.map("n", "J", "mzJ`z", { desc = "General: Join lines and restore cursor position" })
M.map("n", "<C-d>", "<C-d>zz", { desc = "General: Scroll down half a page and recenter" })
M.map("n", "<C-u>", "<C-u>zz", { desc = "General: Scroll up half a page and recenter" })
M.map("n", "n", "nzzzv", { desc = "General: Find next and recenter" })
M.map("n", "N", "Nzzzv", { desc = "General: Find previous and recenter" })
M.map("n", "*", "*zz", { desc = "General: Search word under cursor and recenter" })
M.map("n", "<leader>;", function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  if line_content:sub(-1) == ";" then
    line_content = line_content:sub(1, -2)
  else
    line_content = line_content .. ";"
  end
  vim.api.nvim_buf_set_lines(0, line - 1, line, false, { line_content })
end, { desc = "General: Toggle semicolon at end of line" })
M.map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Visual: Move visual selection down" })
M.map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Visual: Move visual selection up" })

return M
