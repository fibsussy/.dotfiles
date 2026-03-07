vim.api.nvim_create_user_command(
  'RunMacroOnSearch',
  function(opts)
    local input = vim.fn.input('Search pattern: ')
    if input == '' then
      return
    end

    local pattern = vim.fn.escape(input, '/')
    local cmd
    if opts.range ~= 0 then
      cmd = string.format(
        '%d,%dg/%s/execute "normal! " . (match(getline("."), "%s") + 1) . "|@q"',
        opts.line1, opts.line2, pattern, input
      )
    else
      cmd = string.format(
        'g/%s/execute "normal! " . (match(getline("."), "%s") + 1) . "|@q"',
        pattern, input
      )
    end

    vim.cmd(cmd)
  end,
  { nargs = 0, range = true }
)

vim.keymap.set('n', '<leader>q', ':RunMacroOnSearch<CR>', { desc = 'Run macro on search results' })
vim.keymap.set('x', '<leader>q', ':RunMacroOnSearch<CR>', { desc = 'Run macro on search results' })

return {}
