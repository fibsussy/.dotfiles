return {
  "hrsh7th/nvim-cmp",
  config = function(_, opts)
    local cmp = require "cmp"
    opts.mapping["<Up>"] = cmp.mapping.select_prev_item()
    opts.mapping["<Down>"] = cmp.mapping.select_next_item()
    cmp.setup(opts)
  end,
}
