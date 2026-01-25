-- Setup our custom navigation immediately (not lazy-loaded)
vim.keymap.set('n', '<M-Left>', function()
  -- Try to move left in nvim first
  local original_win = vim.fn.winnr()
  vim.cmd('wincmd h')
  local current_win = vim.fn.winnr()
  
  -- If we didn't move (same window), try tmux previous window
  if current_win == original_win then
    local cur_tmux_win = tonumber(vim.fn.system('tmux display -p "#{window_index}" 2>/dev/null'):gsub('%s+', '') or '1')
    if cur_tmux_win > 1 then
      vim.fn.system('tmux previous-window')
    end
  end
end, { desc = 'Smart Navigate Left', silent = true })

vim.keymap.set('n', '<M-Right>', function()
  -- Try to move right in nvim first
  local original_win = vim.fn.winnr()
  vim.cmd('wincmd l')
  local current_win = vim.fn.winnr()
  
  -- If we didn't move (same window), try tmux next window
  if current_win == original_win then
    local cur_tmux_win = tonumber(vim.fn.system('tmux display -p "#{window_index}" 2>/dev/null'):gsub('%s+', '') or '1')
    local total_tmux_wins = tonumber(vim.fn.system('tmux display -p "#{session_windows}" 2>/dev/null'):gsub('%s+', '') or '1')
    if cur_tmux_win < total_tmux_wins then
      vim.fn.system('tmux next-window')
    end
  end
end, { desc = 'Smart Navigate Right', silent = true })

vim.keymap.set('n', '<M-Up>', function()
  -- Try to move up in nvim first
  local original_win = vim.fn.winnr()
  vim.cmd('wincmd k')
  local current_win = vim.fn.winnr()
  
  -- If we didn't move (same window), try tmux session up (lower index)
  if current_win == original_win then
    vim.fn.system('~/.config/tmux/session_info.sh prev')
  end
end, { desc = 'Smart Navigate Up', silent = true })

vim.keymap.set('n', '<M-Down>', function()
  -- Try to move down in nvim first
  local original_win = vim.fn.winnr()
  vim.cmd('wincmd j')
  local current_win = vim.fn.winnr()
  
  -- If we didn't move (same window), try tmux session down (higher index)
  if current_win == original_win then
    vim.fn.system('~/.config/tmux/session_info.sh down')
  end
end, { desc = 'Smart Navigate Down', silent = true })

return {
  {
    "numToStr/Navigator.nvim",
    cmd = {
      "NavigatorUp",
      "NavigatorDown",
      "NavigatorPrevious",
      "NavigatorLeft",
      "NavigatorRight",
    },
    keys = {
      { "<C-Left>", "<cmd>NavigatorLeft<cr>", desc = "Navigator: Window Left" },
      { "<C-Down>", "<cmd>NavigatorDown<cr>", desc = "Navigator: Window Down" },
      { "<C-Up>", "<cmd>NavigatorUp<cr>", desc = "Navigator: Window Up" },
      { "<C-Right>", "<cmd>NavigatorRight<cr>", desc = "Navigator: Window Right" },
    },
    opts = {
      auto_save = nil,
      disable_when_zoomed = false,
      post_hook = nil,
      pre_hook = nil,
    },
    config = function(_, opts)
      require('Navigator').setup(opts)
    end,
  },
}
