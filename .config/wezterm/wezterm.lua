local wezterm = require("wezterm")

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():toggle_fullscreen()
end)

return {
	use_ime = true,

	-- font
	font = wezterm.font("JetBrainsMono Nerd Font"),
	font_size = 13.0,
	color_scheme = "Catppuccin Mocha",

	-- window
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	window_decorations = "NONE",
}
