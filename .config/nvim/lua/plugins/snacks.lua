---@type NvPluginSpec
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = {
        enabled = true,
        width = 64,
        preset = {
          header = [[
 Powered By  eovim
]],
          keys = {
            {
              icon = " ",
              key = "f",
              desc = "Find File",
              action = function()
                require("snacks").picker.files { hidden = true }
              end,
            },
            {
              icon = " ",
              key = "g",
              desc = "Find Word",
              action = function()
                require("snacks").picker.grep()
              end,
            },
            {
              icon = " ",
              key = "r",
              desc = "Recent Files",
              action = function()
                require("snacks").picker.recent()
              end,
            },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = function()
                require("snacks").picker.files { cwd = vim.fn.stdpath "config" }
              end,
            },
            {
              icon = " ",
              key = "q",
              desc = "Quit",
              action = ":qa",
            },
          },
        },
        sections = {
          { section = "header", padding = 1 },
          {
            icon = " ",
            title = "Recent Projects",
            section = "projects",
            indent = 2,
            limit = 5,
            pick = true,
            session = false,
            padding = 1,
          },
          {
            icon = " ",
            title = "Recent Files",
            section = "recent_files",
            indent = 2,
            limit = 8,
            padding = 1,
          },
          {
            icon = " ",
            title = "Shortcuts",
            section = "keys",
            indent = 2,
            gap = 1,
            padding = 1,
          },
          { section = "startup", padding = 1 },
        },
      },
      git = { enabled = true },
      picker = { enabled = true },
      input = { enabled = true },
    },
  },
}
