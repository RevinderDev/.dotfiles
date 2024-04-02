local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Styling
config.color_scheme = "Gruvbox dark, medium (base16)"
config.font = wezterm.font_with_fallback({
	{
		family = "IosevkaTerm Nerd Font",
		harfbuzz_features = {
			"liga", -- (default) ligatures
			"clig", -- (default) contextual ligatures
		},
	},
})

config.tab_max_width = 50
config.colors = {
	tab_bar = {
		background = "#3c3836",
		inactive_tab_edge = "#3c3836",

		active_tab = {
			bg_color = "#282828",
			fg_color = "#97971a",
			intensity = "Bold",
		},

		inactive_tab = {
			bg_color = "#3c3836",
			fg_color = "#665c54",
		},

		inactive_tab_hover = {
			bg_color = "#282828",
			fg_color = "#665c54",
			italic = true,
		},

		new_tab = {
			bg_color = "#3c3836",
			fg_color = "#665c54",
		},

		new_tab_hover = {
			bg_color = "#282828",
			fg_color = "#665c54",
			italic = true,
		},
	},
}

-- Window
config.enable_tab_bar = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.window_decorations = "NONE"
config.skip_close_confirmation_for_processes_named = {}
config.font_size = 12
config.window_background_opacity = 0.9
config.adjust_window_size_when_changing_font_size = false

-- Keybindings
local act = wezterm.action
config.keys = {
	-- Tabs
	{ key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "q", mods = "CTRL", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "e", mods = "CTRL", action = act.ShowTabNavigator },
	{
		key = "r",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Panes
	{ key = "n", mods = "CTRL", action = act({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
	{ key = "p", mods = "CTRL", action = act({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
	{ key = "w", mods = "CTRL", action = act.CloseCurrentPane({ confirm = true }) },

	-- Navigating
	{ key = "LeftArrow", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "ALT", action = act.ActivatePaneDirection("Down") },

	{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },

	{ key = "LeftArrow", mods = "ALT|CTRL", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "DownArrow", mods = "ALT|CTRL", action = act.AdjustPaneSize({ "Down", 5 }) },
	{ key = "UpArrow", mods = "ALT|CTRL", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "RightArrow", mods = "ALT|CTRL", action = act.AdjustPaneSize({ "Right", 5 }) },

	-- Fonts
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "+", mods = "CTRL", action = act.IncreaseFontSize },

	-- Search
	{ key = "H", mods = "SHIFT|CTRL", action = act.Search({ CaseSensitiveString = "" }) },
	{ key = "H", mods = "CTRL", action = act.Search({ CaseInSensitiveString = "" }) },
}

return config
