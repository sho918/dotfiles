---@type NvPluginSpec
return {
  {
    "linux-cultist/venv-selector.nvim",
    ft = "python",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      options = {
        picker = "snacks",
      },
    },
  },
}
