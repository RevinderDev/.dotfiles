local wezterm = require("wezterm")
local utilities = require("utilities")
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
		background = "282828",
		inactive_tab_edge = "#282828",

		active_tab = {
			bg_color = "#282828",
			fg_color = "#97971a",
			intensity = "Bold",
		},

		inactive_tab = {
			bg_color = "#282828",
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

wezterm.on("update-status", function(window, pane)
	local present, conf = pcall(window.effective_config, window)
	if not present then
		return
	end

	local palette = conf.resolved_palette

	-- left status
	local left_cells = {
		{ Background = { Color = palette.tab_bar.background } },
	}
	local process = pane:get_foreground_process_name()
	if not process then
		goto set_left_status
	end
	table.insert(left_cells, { Foreground = { Color = palette.ansi[8] } })
	table.insert(left_cells, {
		-- Get's the full path process e.g. `/usr/bin/zsh` and turns it into `zsh`
		Text = " " .. wezterm.nerdfonts.cod_multiple_windows .. " " .. process
			:gsub("(.*[/\\])(.*)%.(.*)", "%2")
			:match("[^/]+$") .. " ",
	})

	::set_left_status::
	window:set_left_status(wezterm.format(left_cells))

	-- right status
	local right_cells = {
		{ Background = { Color = palette.tab_bar.background } },
	}

	local callbacks = {
		{
			name = "calendar",
			func = function()
				return wezterm.strftime("%A %Y-%b-%d")
			end,
			icon = wezterm.nerdfonts.md_calendar_month,
		},
		{
			name = "clock",
			func = function()
				return wezterm.time.now():format("%H:%M")
			end,
			icon = wezterm.nerdfonts.md_av_timer,
		},
		{
			name = "cwd",
			func = function()
				local search_for_git_root = true
				return utilities.get_cwd(pane, search_for_git_root)
			end,
			icon = wezterm.nerdfonts.oct_file_directory,
		},
	}
	for _, callback in ipairs(callbacks) do
		local func = callback.func
		local text = func()
		if #text > 0 then
			table.insert(right_cells, { Text = text .. " " .. callback.icon })
			table.insert(right_cells, { Foreground = { Color = palette.ansi[8] } })
			table.insert(right_cells, { Text = " | " })
		end
	end
	-- remove trailing separator
	table.remove(right_cells, #right_cells)
	table.insert(right_cells, { Text = string.rep(" ", 2) })
	window:set_right_status(wezterm.format(right_cells))
end)

wezterm.on("format-tab-title", function(tab, _, _, conf, _, _)
	local index = tab.tab_index + 1
	local title = " [" .. index .. "] " .. utilities.get_tab_title(tab) .. " "

	local width = 15
	if #title > width then
		title = wezterm.truncate_right(title, width) .. "…"
	end

	return {
		{ Text = title },
	}
end)

-- Window
config.enable_tab_bar = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"
config.skip_close_confirmation_for_processes_named = {}
config.font_size = 12
config.window_background_opacity = 0.9
config.adjust_window_size_when_changing_font_size = false
config.show_new_tab_button_in_tab_bar = false

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
