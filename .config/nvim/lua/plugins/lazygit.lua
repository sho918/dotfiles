---@type NvPluginSpec
return {
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitLog",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
      "LazyGitConfig",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
  },
}
