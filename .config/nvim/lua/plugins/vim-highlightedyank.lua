return {
  "machakann/vim-highlightedyank",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.g.highlightedyank_highlight_duration = 500
  end,
}
