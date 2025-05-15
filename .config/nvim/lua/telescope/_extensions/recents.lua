---@brief [[
---Put this in ~/.config/nvim/lua/telescope/_extensions/recents.lua
---Then map :Telescope recents
---@brief ]]

local present, telescope = pcall(require, "telescope")
if not present then
  vim.notify "this plugin requires telescope.nvim"
  return
end

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local config = require "telescope.config"
local make_entry = require "telescope.make_entry"
local devicons = require "nvim-web-devicons"
-- local options = require "plugins.configs.telescope"

local defaults = {
  prompt_title = "Recents",
  command = "fd --type f --hidden --follow --exclude .git --exclude node_modules",
  file_ignore_patterns = { "node_modules" },
  file_previewer = require("telescope.previewers").vim_buffer_cat.new,
  grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
  qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
  buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
  color_devicons = true,
  path_display = { "truncate" },
  winblend = 0,
  border = {},
  borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
  vimgrep_arguments = {
    "rg",
    "-L",
    "--color=never",
    "--no-heading",
    "--with-filename",
    "--line-number",
    "--column",
    "--smart-case",
  },
  prompt_prefix = "   ",
  selection_caret = "  ",
  entry_prefix = "  ",
  initial_mode = "insert",
  selection_strategy = "reset",
  sorting_strategy = "ascending",
  layout_strategy = "horizontal",
  layout_config = {
    horizontal = {
      prompt_position = "top",
      preview_width = 0.55,
      results_width = 0.8,
    },
    vertical = {
      mirror = false,
    },
    width = 0.87,
    height = 0.80,
    preview_cutoff = 120,
  },
}

local function reconfigure(options)
  options = vim.F.if_nil(options, {})
  assert(not options.sorter, "custom sorters are not supported")
  assert(not options.command, "custom command is not supported")
  return vim.tbl_deep_extend("keep", options, defaults)
end

return telescope.register_extension {
  setup = function(options)
    defaults = reconfigure(options)
  end,
  exports = {
    recents = function(options)
      options = reconfigure(options)
      options.entry_maker = make_entry.gen_from_file(options)
      local entries = vim.split(vim.fn.system(options.command), "\n", { plain = true })
      table.remove(entries, #entries)
      table.sort(entries, function(a, b)
        return vim.loop.fs_stat(a).mtime.sec > vim.loop.fs_stat(b).mtime.sec
      end)
      pickers
        .new(options, {
          finder = finders.new_table(entries),
          sorter = config.values.file_sorter(options),
          previewer = config.values.file_previewer(options),
          entry_maker = options.entry_maker,
        })
        :find()
    end,
  },
}
