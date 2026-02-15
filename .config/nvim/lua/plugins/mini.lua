---@type NvPluginSpec
return {
  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    config = function()
      require("mini.cursorword").setup()
      require("mini.indentscope").setup()
      require("mini.trailspace").setup()
      require("mini.extra").setup()
    end,
  },
}
