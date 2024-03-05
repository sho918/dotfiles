return {
  "petertriho/nvim-scrollbar",
  event = { "BufReadPre", "BufNewFile" },
  depends = { "lewis6991/gitsigns.nvim" },
  config = function()
    require("scrollbar").setup()
    require("scrollbar.handlers.gitsigns").setup()
  end,
}
