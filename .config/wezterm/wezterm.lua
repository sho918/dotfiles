local wezterm = require("wezterm")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")

local config = wezterm.config_builder()

config.automatically_reload_config = true
config.use_ime = true
config.scrollback_lines = 5000

-- font
config.font = wezterm.font("UDEV Gothic 35NF")
config.font_size = 14.0
config.color_scheme = "Catppuccin Mocha"
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- window
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.8
config.macos_window_background_blur = 5

-- quick select
config.quick_select_patterns = {
  "[0-9a-zA-Z]+[._-][0-9a-zA-Z._-]+",
}

-- hyuperlinks
config.hyperlink_rules = {}

-- keymap
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
    key = "s",
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
  {
    mods = "LEADER",
    key = "1",
    action = wezterm.action.ActivateTab(0),
  },
  {
    mods = "LEADER",
    key = "2",
    action = wezterm.action.ActivateTab(1),
  },
  {
    mods = "LEADER",
    key = "3",
    action = wezterm.action.ActivateTab(2),
  },
  {
    mods = "LEADER",
    key = "4",
    action = wezterm.action.ActivateTab(3),
  },
  {
    mods = "LEADER",
    key = "5",
    action = wezterm.action.ActivateTab(4),
  },
  {
    mods = "LEADER",
    key = "6",
    action = wezterm.action.ActivateTab(5),
  },
}

smart_splits.apply_to_config(config)
return config
