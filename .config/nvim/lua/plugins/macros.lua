vim.api.nvim_create_user_command(
  'RunMacroOnSearch',
  function(opts)
    local input = vim.fn.input('Search pattern: ')
    if input == '' then
      return
    end

    local cmd
    if opts.range ~= 0 then
      cmd = string.format('%d,%dg/%s/normal! @q', opts.line1, opts.line2, vim.fn.escape(input, '/'))
    else
      cmd = string.format('g/%s/normal! @q', vim.fn.escape(input, '/'))
    end

    vim.cmd(cmd)
  end,
  { nargs = 0, range = true }
)

vim.keymap.set('n', '<leader>mr', ':RunMacroOnSearch<CR>', { desc = 'Run macro on search results' })
vim.keymap.set('x', '<leader>mr', ':RunMacroOnSearch<CR>', { desc = 'Run macro on search results' })

return {}
