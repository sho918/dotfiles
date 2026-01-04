---@type NvPluginSpec
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      git = { enabled = true },
      picker = { enabled = true },
      input = { enabled = true },
    },
  },
}
