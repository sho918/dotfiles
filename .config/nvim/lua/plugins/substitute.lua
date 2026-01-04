---@type NvPluginSpec
return {
  {
    "gbprod/substitute.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      require("substitute").setup(opts)
    end,
  },
}
