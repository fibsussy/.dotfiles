return {
  {
    "monaqa/dial.nvim",
    -- branch = "feat-augend-lsp",
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
        {
          "estj","estp","entj","enfj",
          "esfj","esfp","entp","enfp",
          "istj","istp","intj","infj",
          "isfj","isfp","intp","infp",
        },
        {"sdsf", "sduf", "udsf", "uduf"},
        {"true", "false"},
        {"yes", "no"},
        {"on", "off"},
        {"enable", "disable"},
        {"enabled", "disabled"},
        {"null", "undefined"},
        {"public", "private", "protected"},
        {"let", "const", "var"},
        {"and", "or"},
        {"&&", "||", opts = {word=false}, },
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
        {"seconds", "minutes", "hours", "days", "weeks", "months", "years"},
        {"second", "minute", "hour", "day", "week", "month", "year"},
        {"secs", "mins", "hrs", "days", "wks", "mos", "yrs"},
        {"sec", "min", "hr", "day", "wk", "mo", "yr"},
      }


      local augend = require("dial.augend")
      local augends = {
        -- augend.lsp_enum.new({}),
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

      for _, list in ipairs(custom_lists) do
        local options = {
          word = true, -- Match whole words only by default
          cyclic = true, -- Cycle through the list (e.g., "sunday" to "monday")
          preserve_case = true, -- Preserve case (e.g., "True" to "False")
        }
        
        local elements = list
        if list.opts then
          local custom_opts = list.opts
          list.opts = nil
          for k, v in pairs(custom_opts) do
            options[k] = v
          end
        end
        options.elements = list
        table.insert(augends, augend.constant.new(options))
      end

      require("dial.config").augends:register_group({
        default = augends,
      })
    end,
  },
}
