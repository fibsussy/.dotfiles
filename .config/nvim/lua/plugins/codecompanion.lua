return {
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionToggle" },
    keys = {
      { "<leader>cc", "<cmd>CodeCompanionToggle<cr>", desc = "Toggle CodeCompanion" },
      { "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion Actions" },
    },
    opts = {
      strategies = {
        chat = {
          adapter = "anthropic",
        },
        inline = {
          adapter = "anthropic",
        },
      },
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "cmd: echo $ANTHROPIC_API_KEY",
            },
          })
        end,
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
