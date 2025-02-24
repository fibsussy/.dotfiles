return {
  "Eandrju/cellular-automaton.nvim",
  lazy = true,
  cmd = { "CellularAutomaton" },
  config = function()
    local ca = require("cellular-automaton")
    
    ca.register_animation {
      fps = 80,
      name = "slide",
      update = function(grid)
        for i = 1, #grid do
          local prev = grid[i][#grid[i]]
          for j = 1, #grid[i] do
            grid[i][j], prev = prev, grid[i][j]
          end
        end
        return true
      end,
    }

    vim.keymap.set("n", "<leader>rb", function()
      local animations = {}
      for name, _ in pairs(ca.animations) do
        table.insert(animations, name)
      end
      ca.start_animation(animations[math.random(#animations)])
    end, { desc = "CellularAutomaton random animation" })
  end,
}
