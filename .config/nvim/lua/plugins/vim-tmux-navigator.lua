return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<C-h>", "<cmd><C-U>TmuxNavigateLeft<CR>" },
    { "<C-j>", "<cmd><C-U>TmuxNavigateDown<CR>" },
    { "<C-k>", "<cmd><C-U>TmuxNavigateUp<CR>" },
    { "<C-l>", "<cmd><C-U>TmuxNavigateRight<CR>" },
  },
}
