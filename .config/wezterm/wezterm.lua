local wezterm = require("wezterm")

return {
  automatically_reload_config = true,
  use_ime = true,

  -- font
  font = wezterm.font("UDEV Gothic 35NF"),
  font_size = 14.0,
  color_scheme = "Catppuccin Mocha",
  harfbuzz_features = { "calt=0", "clig=0", "liga=0" },

  -- window
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,
  window_decorations = "RESIZE",
  window_background_opacity = 0.8,
  macos_window_background_blur = 5,

  -- keymap
  disable_default_key_bindings = true,
  keys = require("keybinds").keys,
  key_tables = require("keybinds").key_tables,
  leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1500 },
}
