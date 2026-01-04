---@type NvPluginSpec
return {
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = true,
      float = {
        padding = 1,
        max_width = 0.6,
        max_height = 0.6,
        border = "rounded",
      },
    },
  },
}
