return {
  "nvim-web-devicons",
  event = "VeryLazy",
  opts = {
    default = true,
    strict = false,
    override = {
      [".env.dev"] = {
        icon = "",
        color = "#50FA7B",   -- Green (like a healthy base environment)
        name = "EnvDev",
      },
      [".env.local"] = {
        icon = "",
        color = "#FFB86C",   -- Orange (warning - local modifications)
        name = "EnvLocal",
      },
      [".env.prod"] = {
        icon = "",
        color = "#FF5555",   -- Red (important production warning)
        name = "EnvProd",
      },
    },
  },
}
