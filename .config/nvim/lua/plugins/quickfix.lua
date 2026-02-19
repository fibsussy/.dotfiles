return {
  {
    "kevinhwang91/nvim-bqf",
    dependencies = "junegunn/fzf",
    event = "VeryLazy",
    ft = "qf",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        callback = function(args)
          local buf = args.buf
          vim.keymap.set("n", "<Down>", "j", { buffer = buf, silent = true })
          vim.keymap.set("n", "<Up>", "k", { buffer = buf, silent = true })
          vim.keymap.set("n", "<Enter>", "<CR>", { buffer = buf, silent = true })
        end,
      })
    end,
  },
  {
    "itchyny/vim-qfedit",
    event = "BufRead",
  },
}
