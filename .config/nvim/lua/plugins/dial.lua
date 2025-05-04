return {
  {
    "monaqa/dial.nvim",
    keys = {
      { "<C-a>", function() require("dial.map").manipulate("increment", "normal") end, },
      { "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end, },
      { "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end, },
      { "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end, },
      { mode={"v"}, "<C-a>", function() require("dial.map").manipulate("increment", "visual") end, },
      { mode={"v"}, "<C-x>", function() require("dial.map").manipulate("decrement", "visual") end, },
      { mode={"v"}, "g<C-a>", function() require("dial.map").manipulate("increment", "gvisual") end, },
      { mode={"v"}, "g<C-x>", function() require("dial.map").manipulate("decrement", "gvisual") end, },
    },
    config = function()
      local custom_lists = {
        {"foo", "bar"},
        {"tic", "tac", "toe"},
        {"monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"},
        {"mon", "tue", "wed", "thu", "fri", "sat", "sun"},
        {"january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"},
        {"jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"},
        {"spring", "summer", "fall", "winter"},
        {"north", "northeast", "east", "southeast", "south", "southwest", "west", "northwest"},
        {"true", "false"},
        {"yes", "no"},
        {"on", "off"},
        {"enable", "disable"},
        {"enabled", "disabled"},
        {"null", "undefined"},
        {"public", "private", "protected"},
        {"let", "const", "var"},
        {"and", "or"},
        {"&&", "||"},
        {"if", "else", "elif"},
        {"min", "max"},
        {"minimum", "maximum"},
        {"start", "end"},
        {"first", "last"},
        {"open", "close"},
        {"read", "write"},
        {"input", "output"},
        {"in", "out"},
        {"up", "down"},
        {"left", "right"},
        {"top", "bottom"},
        {"width", "height"},
        {"row", "column"},
        {"div", "span"},
        {"block", "inline", "flex", "grid"},
        {"margin", "padding"},
        {"absolute", "relative", "fixed", "sticky"},
        {"second", "minute", "hour", "day", "week", "month", "year"},
        {"seconds", "minutes", "hours", "days", "weeks", "months", "years"},
        {"sec", "min", "hr", "day", "wk", "mo", "yr"},
        {"secs", "mins", "hrs", "days", "wks", "mos", "yrs"},
      }


      local augend = require("dial.augend")
      local default_augends = {
        augend.integer.alias.decimal_int,
        augend.integer.alias.hex,
        augend.integer.alias.octal,
        augend.integer.alias.binary,
        augend.date.alias["%Y/%m/%d"],
        augend.date.alias["%H:%M:%S"],
        augend.date.alias["%H:%M"],
        augend.semver.alias.semver,
        augend.constant.alias.alpha,
        augend.constant.alias.Alpha,
        augend.constant.alias.ja_weekday,
        augend.constant.alias.ja_weekday_full,
        augend.constant.alias.bool,
      }

      local custom_augends = {}
      for _, list in ipairs(custom_lists) do
        table.insert(custom_augends, augend.constant.new({
          elements = list,
          word = true, -- Match whole words only
          cyclic = true, -- Cycle through the list (e.g., "sunday" to "monday")
          preserve_case = true, -- Preserve case (e.g., "True" to "False")
        }))
      end

      local all_augends = vim.list_extend(default_augends, custom_augends)

      require("dial.config").augends:register_group({
        default = all_augends,
      })
    end,
  },
}
