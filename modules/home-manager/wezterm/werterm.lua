local wezterm = require("wezterm")
local config = wezterm.config_builder()
config.color_scheme = "Afterglow"
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.8
config.window_decorations = "NONE"
config.max_fps = 120
config.audible_bell = "Disabled"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
return config
