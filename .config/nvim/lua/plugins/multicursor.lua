---@type NvPluginSpec
return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    config = function()
      require("multicursor-nvim").setup()
    end,
  },
}
