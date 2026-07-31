-- イベントハンドラの登録のみを行う。config の設定は wezterm.lua 側で行うこと
-- (ここで config_builder() を作っても require("on") の戻り値は使われず捨てられる)
local wezterm = require("wezterm")

wezterm.on("toggle-opacity", function(window, _)
	local overrides = window:get_config_overrides() or {}

	if overrides.window_background_opacity == nil then
		overrides.window_background_opacity = 0.9
    overrides.win32_system_backdrop = "Disable"

  elseif overrides.window_background_opacity == 0.9 then
    overrides.window_background_opacity = 0.6
    overrides.win32_system_backdrop = "Acrylic"

	else
		overrides.window_background_opacity = nil
    overrides.win32_system_backdrop = nil
	end

	window:set_config_overrides(overrides)
end)

wezterm.on("bell", function(window, pane)
	window:toast_notification("Wezterm", pane:get_title() .. "が完了/通知", nil, 4000)
end)
