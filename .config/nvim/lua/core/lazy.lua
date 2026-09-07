-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    cond = function(plugin)
      local disabled = vim.g.notepad_disabled
      return not disabled or not vim.tbl_contains(disabled, plugin.name)
    end,
  },
  checker = {
    enabled = false,
    notify = false,
  },
  -- Don't watch config files for changes at startup (removes the "config changed,
  -- reloading" popups and a small amount of startup work).
  change_detection = {
    enabled = false,
  },
  -- No plugin here uses luarocks (image.nvim runs magick_cli with build=false), so
  -- skip lazy's rocks/hererocks bootstrap entirely.
  rocks = {
    enabled = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "spellfile",
        "shada",
      },
    },
    reset_packpath = true,
  },
  ui = {
    size = { width = 0.8, height = 0.8 },
  },
})

