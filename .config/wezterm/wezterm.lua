local wezterm = require("wezterm")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
local balance = require("balance")

local config = wezterm.config_builder()

-- general
-- https://wezterm.org/config/lua/config/automatically_reload_config.html
-- https://wezterm.org/config/lua/config/use_ime.html
-- https://wezterm.org/config/lua/config/scrollback_lines.html
config.automatically_reload_config = true
config.use_ime = true
config.scrollback_lines = 5000

-- font
-- https://wezterm.org/config/lua/config/font.html
-- https://wezterm.org/config/lua/config/font_size.html
-- https://wezterm.org/config/lua/config/color_scheme.html
-- https://wezterm.org/config/lua/config/harfbuzz_features.html
config.font = wezterm.font("UDEV Gothic 35NF")
config.font_size = 14.0
config.color_scheme = "Catppuccin Mocha"
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- window
-- https://wezterm.org/config/lua/config/enable_tab_bar.html
-- https://wezterm.org/config/lua/config/hide_tab_bar_if_only_one_tab.html
-- https://wezterm.org/config/lua/config/window_decorations.html
-- https://wezterm.org/config/lua/config/window_background_opacity.html
-- https://wezterm.org/config/lua/config/macos_window_background_blur.html
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.8
config.macos_window_background_blur = 5

-- quick select
-- https://wezterm.org/config/lua/config/quick_select_patterns.html
config.quick_select_patterns = {
  "[0-9a-zA-Z]+[._-][0-9a-zA-Z._-]+",
}

-- hyperlinks
-- https://wezterm.org/config/lua/config/hyperlink_rules.html
config.hyperlink_rules = {
  {
    regex = [[\bhttps://[\w.-]+\.[a-zA-Z]{2,15}\S*\b]],
    format = "$0",
  },
  {
    regex = [[\bhttps://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
    format = "$0",
  },
}

-- keymap
-- https://wezterm.org/config/lua/config/leader.html
-- https://wezterm.org/config/lua/config/keys.html
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1500 }
config.keys = {
  {
    mods = "LEADER",
    key = "-",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    mods = "LEADER",
    key = "\\",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    mods = "LEADER",
    key = "z",
    action = wezterm.action.TogglePaneZoomState,
  },
  {
    mods = "LEADER",
    key = "f",
    action = wezterm.action.QuickSelect,
  },
  {
    mods = "LEADER",
    key = "w",
    action = wezterm.action.ShowLauncherArgs({ flags = "WORKSPACES", title = "Select workspace" }),
  },
  {
    mods = "LEADER",
    key = ",",
    action = wezterm.action.PromptInputLine({
      description = "(wezterm) Set workspace title:",
      action = wezterm.action_callback(function(win, pane, line)
        if line then
          wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
        end
      end),
    }),
  },
  {
    mods = "LEADER",
    key = "Space",
    action = wezterm.action.PaneSelect({
      mode = "SwapWithActive",
    }),
  },
  {
    mods = "LEADER",
    key = "Enter",
    action = wezterm.action.ActivateCopyMode,
  },
  -- for Claude Code
  {
    key = "Enter",
    mods = "SHIFT",
    action = wezterm.action.SendString("\n"),
  },
  -- Balance panes horizontally (left/right)
  {
    mods = "LEADER",
    key = "=",
    action = wezterm.action_callback(balance.balance_panes("x")),
  },
  -- Balance panes vertically (up/down)
  {
    mods = "LEADER",
    key = "+",
    action = wezterm.action_callback(balance.balance_panes("y")),
  },
  -- Leader + a + a  -> ctrl+a
  {
    key = "a",
    mods = "LEADER",
    action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
  },
}

smart_splits.apply_to_config(config)
return config
