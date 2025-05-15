return {
  { "ray-x/go.nvim", ft="go", },
  { "ray-x/guihua.lua", ft="go", },
  { "tpope/vim-sleuth", event = "BufReadPre", },
  { "numToStr/Comment.nvim", event = "VeryLazy", },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", event="BufReadPost", },
  { "folke/twilight.nvim", ft = "markdown" },
  { "djoshea/vim-autoread", event = "BufRead" },
}
