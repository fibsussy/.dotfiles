local M = {
    mappings = {},
}
function M.nomap(mode, lhs)
  table.insert(M.mappings, { action = "nomap", mode = mode, lhs = lhs })
end
function M.map(mode, lhs, rhs, opts)
  opts = opts or {
    expr = true,
    silent = true,
    noremap = true,
  }
  table.insert(M.mappings, { action = "nomap", mode = mode, lhs = lhs })
  table.insert(M.mappings, { action = "map", mode = mode, lhs = lhs, rhs = rhs, opts = opts })
end


M.map("n", "<C-s>", "<cmd> w <cr>", { desc = "Save Buffer" })
M.map("n", "<C-a>", "ggVG", { desc = "Select All Buffer" })
M.map("n", "<C-c>", "<cmd> %y+ <cr>", { desc = "Copy All Buffer" })
M.map("n", "<leader>q", "<cmd> bd! <cr>", { desc = "Close Buffer" })
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



function M.init()
  for _, m in ipairs(M.mappings) do
    local status, err
    if m.action == "nomap" then
      status, err = pcall(vim.keymap.del, m.mode, m.lhs)
      if not status then
        if not err:match("E31: No such mapping") then
          error(string.format("Error unmapping key: mode=%s lhs=%s error=%s", m.mode, m.lhs, err))
        end
      end
    elseif m.action == "map" then
      status, err = pcall(vim.keymap.set, m.mode, m.lhs, m.rhs, m.opts)
      if not status then
        error(string.format("Error setting keymap: mode=%s lhs=%s rhs=%s opts=%s error=%s",
          m.mode, m.lhs, m.rhs, vim.inspect(m.opts), err))
      end
    end
  end
end

M.init()

return M
