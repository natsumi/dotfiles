local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font("BerkeleyMono Nerd Font")
config.font_size = 14

-- Rendering
config.max_fps = 75

-- Bell
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_duration_ms = 0,
	fade_out_duration_ms = 0,
}

-- Theme
config.color_scheme = "Catppuccin Macchiato"

-- Cursor
config.default_cursor_style = "SteadyBlock"

-- Mouse
config.hide_mouse_cursor_when_typing = true

-- Window
config.native_macos_fullscreen_mode = false

-- Scrollback
config.scrollback_lines = 5000

-- Keys
-- Fix for Claude
config.keys = {
	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action.SendString("\x1b[200~\n\x1b[201~"),
	},
}

return config
