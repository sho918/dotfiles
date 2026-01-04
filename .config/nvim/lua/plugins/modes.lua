---@type NvPluginSpec
return {
  {
    "mvllow/modes.nvim",
    event = "VeryLazy",
    opts = {
      set_cursor = true,
      set_cursorline = true,
      set_number = true,
      set_signcolumn = true,
      line_opacity = 0.15,
      ignore = { "NvimTree", "Trouble", "Noice", "notify" },
    },
  },
}
