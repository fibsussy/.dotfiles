return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>m", desc = "Harpoon add file" },
      { "<leader>ht", desc = "Harpoon toggle menu" },
      { "<leader>sh", desc = "Harpoon search files" },
    },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      local conf = require("telescope.config").values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end
        require("telescope.pickers").new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table({ results = file_paths }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        }):find()
      end

      vim.keymap.set("n", "<leader>m", function() harpoon:list():add() end, { desc = "Harpoon add file" })
      vim.keymap.set("n", "<leader>ht", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon toggle menu" })
      vim.keymap.set("n", "<leader>sh", function() toggle_telescope(harpoon:list()) end, { desc = "Harpoon search files" })
    end,
  },
}
