local wezterm_ready = vim.env.WEZTERM_PANE ~= nil and vim.env.WEZTERM_PANE ~= "" and vim.env.SMART_SPLITS_WEZTERM ~= nil

---@type NvPluginSpec
return {
  {
    "smart-splits-nvim/smart-splits.nvim",
    version = "^3.0.0",
    lazy = false,
    dependencies = {
      {
        "smart-splits-nvim/backend-wezterm",
        main = "smart-splits-backend-wezterm",
        opts = {},
      },
    },
    opts = {
      ignored_buftypes = { "nofile", "quickfix", "prompt" },
      ignored_filetypes = { "NvimTree" },
      resize = { amount = 3 },
      mux = { backend = wezterm_ready and "smart-splits-backend-wezterm" or nil },
      log = { level = "info" },
    },
  },
}
