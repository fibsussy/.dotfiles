return {
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      { "<leader>e", "<cmd> Oil --preview <cr>", desc = "Open Oil (explorer)" },
    },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      columns = { "icon" },
      default_file_explorer = true,
      restore_win_options = true,
      use_default_keymaps = false,
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-p>"] = "actions.preview",
        ["<C-n>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
      },
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
          return name == ".."
        end,
      },
      preview_win = {
        preview_split = "right",
      },
    },
  },
}
