vim.api.nvim_create_user_command(
  'GcodeMath',
  function(opts)
    local input
    repeat
      local success
      success, input = pcall(vim.fn.input, 'Enter axis and operation (e.g. Y+69.42, X-5.1, Z*2): ')
      
      if not success or input == "" then
        return
      end

      if not input:match('^([A-Z])([+/*%-])([%d%.]+)$') then
        vim.notify('Format must be: AXISOPERATION (e.g. Y+69.42)\n'..
                   'First letter: Axis (A-Z)\n'..
                   'Second char: + - * /\n'..
                   'Rest: Number', vim.log.levels.ERROR)
      end
    until input:match('^([A-Z])([+/*%-])([%d%.]+)$')

    local axis, op, num = input:match('^([A-Z])([+/*%-])([%d%.]+)$')
    local num_val = tonumber(num)

    if not vim.bo.modifiable then
      vim.notify("The buffer is not modifiable. Cannot make changes.", vim.log.levels.ERROR)
      return
    end
    
    local cmd
    if opts.range ~= 0 then
      cmd = string.format(
        [[%d,%ds/%s\zs\(-\?\d\+\.\d\+\|\d\+\)/\=substitute(printf('%%0.4f', eval(submatch(0)) %s %f), '\.0\+$', '', '')/g]],
        opts.line1, opts.line2, axis, op, num_val
      )
    else
      cmd = string.format(
        [[%%s/%s\zs\(-\?\d\+\.\d\+\|\d\+\)/\=substitute(printf('%%0.4f', eval(submatch(0)) %s %f), '\.0\+$', '', '')/g]],
        axis, op, num_val
      )
    end

    vim.cmd(cmd)
  end,
  { nargs = 0, range = true }
)

return {}
