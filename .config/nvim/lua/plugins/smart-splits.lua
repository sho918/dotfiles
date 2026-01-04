---@type NvPluginSpec
return {
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    init = function()
      -- Needed early for WezTerm integration
      vim.g.smart_splits_multiplexer_integration = "wezterm"
    end,
    config = function()
      require("smart-splits").setup {
        ignored_buftypes = { "nofile", "quickfix", "prompt" },
        ignored_filetypes = { "NvimTree" },
        default_amount = 3,
        disable_multiplexer_nav_when_zoomed = true,
        log_level = "info",
      }
    end,
  },
}
