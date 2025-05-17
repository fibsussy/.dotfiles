return {
  "Eandrju/cellular-automaton.nvim",
  cmd = { "CellularAutomaton" },
  keys = {
    {
      "<leader>rb",
      function()
        local animations = {}
        local ca = require("cellular-automaton")
        for name, _ in pairs(ca.animations) do
          table.insert(animations, name)
        end
        ca.start_animation(animations[math.random(#animations)])
      end,
      desc = "CellularAutomaton random animation",
    },
  },
  config = function()
    require("cellular-automaton").register_animation {
      fps = 144,
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
  end,
}
