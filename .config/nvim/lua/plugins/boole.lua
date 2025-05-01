return {
  {
    "nat-418/boole.nvim",
    opts = {
      mappings = {
        increment = '<C-a>',
        decrement = '<C-x>'
      },
      allow_caps_additions = {
        -- custom
        {'foo', 'bar'},
        {'tic', 'tac', 'toe'},

        -- days of week (full)
        {'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'},

        -- days of week (short)
        {'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'},

        -- months (full)
        {'january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december'},

        -- months (short)
        {'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'},

        -- seasons
        {'spring', 'summer', 'fall', 'winter'},

        -- cardinal and ordinal directions
        {'north', 'northeast', 'east', 'southeast', 'south', 'southwest', 'west', 'northwest'},

        -- boolean values
        {'true', 'false'},
        {'yes', 'no'},
        {'on', 'off'},
        {'enable', 'disable'},
        {'enabled', 'disabled'},

        -- common programming terms
        {'public', 'private', 'protected'},
        {'let', 'const', 'var'},
        {'and', 'or'},
        {'if', 'else', 'elif'},
        {'min', 'max'},
        {'minimum', 'maximum'},
        {'start', 'end'},
        {'first', 'last'},
        {'open', 'close'},
        {'read', 'write'},
        {'input', 'output'},
        {'in', 'out'},
        {'up', 'down'},
        {'left', 'right'},
        {'top', 'bottom'},
        {'width', 'height'},
        {'row', 'column'},

        -- html/css related
        {'div', 'span'},
        {'block', 'inline', 'flex', 'grid'},
        {'margin', 'padding'},
        {'absolute', 'relative', 'fixed', 'sticky'},

        -- time units
        {'second', 'minute', 'hour', 'day', 'week', 'month', 'year'},
        {'seconds', 'minutes', 'hours', 'days', 'weeks', 'months', 'years'},
        {'sec', 'min', 'hr', 'day', 'wk', 'mo', 'yr'},
        {'secs', 'mins', 'hrs', 'days', 'wks', 'mos', 'yrs'},
      },
    },
  },
}
