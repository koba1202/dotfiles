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

-- SSH先のプロンプトがタイトル設定シーケンスをBEL終端で送ってくる(Debian/Ubuntu系.bashrcの既定)ため、
-- コマンド実行のたびにbellイベントが誤発火する。paneごとに直近の発火から一定時間内の連発を間引く。
local BELL_DEBOUNCE_SECONDS = 3
local last_bell_at = {}

wezterm.on("bell", function(window, pane)
	local pane_id = pane:pane_id()
	local now = os.time()
	local last = last_bell_at[pane_id]
	if last and (now - last) < BELL_DEBOUNCE_SECONDS then
		return
	end
	last_bell_at[pane_id] = now

	window:toast_notification("Wezterm", pane:get_title() .. "が完了/通知", nil, 4000)
end)
