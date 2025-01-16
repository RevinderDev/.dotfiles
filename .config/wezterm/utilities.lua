local M = {}
local wezterm = require("wezterm")

-- Credits to https://github.com/adriankarlen/bar.wezterm for these functions!

---@type string
local home = (os.getenv("USERPROFILE") or os.getenv("HOME") or wezterm.home_dir or ""):gsub("\\", "/")

local find_git_dir = function(directory)
	directory = directory:gsub("~", home)

	while directory do
		local handle = io.open(directory .. "/.git/HEAD", "r")
		if handle then
			handle:close()
			directory = directory:match("([^/]+)$")
			return directory
		elseif directory == "/" or directory == "" then
			break
		else
			directory = directory:match("(.+)/[^/]*")
		end
	end

	return nil
end

function M.get_cwd(pane, search_git_root_instead)
	local cwd = ""
	local cwd_uri = pane:get_current_working_dir()
	if cwd_uri then
		if type(cwd_uri) == "userdata" then
			-- Running on a newer version of wezterm and we have
			-- a URL object here, making this simple!

			---@diagnostic disable-next-line: undefined-field
			cwd = cwd_uri.file_path
		else
			-- an older version of wezterm, 20230712-072601-f4abf8fd or earlier,
			-- which doesn't have the Url object
			cwd_uri = cwd_uri:sub(8)
			local slash = cwd_uri:find("/")
			if slash then
				-- and extract the cwd from the uri, decoding %-encoding
				cwd = cwd_uri:sub(slash):gsub("%%(%x%x)", function(hex)
					return string.char(tonumber(hex, 16))
				end)
			end
		end

		local is_windows = package.config:sub(1, 1) == "\\"
		if is_windows then
			cwd = cwd:gsub("/" .. home .. "(.-)$", "~%1")
		else
			cwd = cwd:gsub(home .. "(.-)$", "~%1")
		end

		---search for the git root of the project if specified
		if search_git_root_instead then
			local git_root = find_git_dir(cwd)
			cwd = git_root or cwd ---fallback to cwd
		end
	end

	return cwd
end

function M.get_tab_title(tab_info)
	-- if the tab title is explicitly set, take that
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end

	-- if a cwd is available then get it
	local cwd = tab_info.active_pane.current_working_dir
	if cwd ~= nil then
		local last_folder = cwd.file_path:match("[^/]+$")
		return last_folder
	end

	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title:gsub("(.*[/\\])(.*)%.(.*)", "%2")
end

return M
