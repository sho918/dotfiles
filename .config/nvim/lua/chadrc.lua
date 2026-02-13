-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "onedark",
  transparency = false,
  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
    CursorLine = { bg = "#2a2a3a" },
    CursorLineNr = { fg = "#fab387", bold = true },
  },
}

M.ui = {
  statusline = {
    theme = "vscode_colored",
    order = { "mode", "git", "%=", "lsp_msg", "%=", "diagnostics", "venv", "lsp", "cursor", "cwd" },
    modules = {
      venv = function()
        local ok, statusline = pcall(require, "venv-selector.statusline.nvchad")
        if not ok then
          return ""
        end
        return statusline.render()
      end,
      cursor = function()
        return "%#StText# Ln %l, Col %v, %p%% "
      end,
    },
  },
  tabufline = {
    modules = {
      btns = function()
        local btn = require("nvchad.tabufline.utils").btn
        return btn(" 󰅖 ", "CloseAllBufsBtn", "CloseAllBufs")
      end,
    },
  },
}

M.nvdash = {
  load_on_startup = true,
  header = {
    "  Powered By  eovim ",
    "                      ",
  },
  buttons = {
    { txt = "  Find File", keys = "ff", cmd = "lua require('snacks').picker.files()" },
    { txt = "  Recent Files", keys = "fr", cmd = "lua require('snacks').picker.recent()" },
    { txt = "󰈭  Find Word", keys = "fw", cmd = "lua require('snacks').picker.grep()" },
    { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
    {
      txt = function()
        local stats = require("lazy").stats()
        local ms = math.floor(stats.startuptime) .. " ms"
        return "  Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms
      end,
      hl = "NvDashFooter",
      no_gap = true,
      content = "fit",
    },
    { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
  },
}
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
