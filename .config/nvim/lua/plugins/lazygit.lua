return {
  "kdheepak/lazygit.nvim",
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>gg", ":LazyGit<CR>", desc = "Open lazygit", silent = true },
    { "<leader>gc", ":LazyGitFilter<CR>", desc = "Open commits (project files)", silent = true },
    { "<leader>gfc", ":LazyGitFilterCurrentFile<CR>", desc = "Open commits (current file)", silent = true },
  },
}
