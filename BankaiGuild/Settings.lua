local ADDON, ns = ...
local L = ns.L

-- The Settings tab: the options each /bk command turns on or off, in one list. A click on a line
-- runs the same setter the command does (with the gamepad UI too: a click on a row, no text box,
-- no popup). Privacy and sharing answers stay on their own page (Consent.lua), one line away.
local Settings = {}
ns.Settings = Settings

local function Green(s) return "|cff40ff40" .. s .. "|r" end
local function Red(s) return "|cffff4040" .. s .. "|r" end
local function Gold(s) return "|cffffd200" .. s .. "|r" end
local function State(on) return on and Green(L.SETTINGS_ON) or Red(L.SETTINGS_OFF) end

local function Refresh() if ns.UI and ns.UI.RefreshSoon then ns.UI.RefreshSoon() end end

-- One on/off line: get() says whether it is on, set(on) changes it, slash names the command.
local function Toggle(lines, label, slash, get, set)
	local on = get() and true or false
	lines[#lines + 1] = {
		text = label, right = State(on), setting = slash, -- (tests)
		onClick = function() ns.SafeCall("settings " .. slash, set, not on); Refresh() end,
		tooltip = function(tt)
			tt:AddLine(label, 1, 0.82, 0)
			tt:AddLine(L.SETTINGS_CLICK:format(slash), 1, 1, 1, true)
		end,
	}
end

local WARN_DAYS = { 3, 7, 14, 30 }
local function NextWarnDays(now)
	for _, d in ipairs(WARN_DAYS) do if d > now then return d end end
	return WARN_DAYS[1]
end
Settings.NextWarnDays = NextWarnDays -- (tests)

-- The keys the reset puts back: ns.DEFAULTS' value where Core.lua has one, else nil (unset is
-- each option's default). Privacy answers and the chats (Consent.lua's questions) are not here:
-- the setup page shows them again after the next /reload, to change any of them.
Settings.RESET_KEYS = { "hideMinimap", "showMates", "sharePosition", "showCamps", "borders", "nameplates",
	"chatMarks", "warnDays", "sound", "soundOff", "alertsAlways", "bowNudge", "windowWidth" }

function Settings.Reset()
	local defaults = ns.DEFAULTS or {}
	for _, k in ipairs(Settings.RESET_KEYS) do ns.db[k] = defaults[k] end
	ns.db.setupDue = true -- the setup page (Consent.lua) opens again after a /reload
	local function Run(name, fn, ...) if type(fn) == "function" then ns.SafeCall("settings reset " .. name, fn, ...) end end
	Run("minimap", ns.UI and ns.UI.UpdateMinimapButton)
	Run("width", ns.UI and ns.UI.SetWidthStep, 1)
	Run("mates", ns.Positions and ns.Positions.Refresh)
	Run("camps", ns.Board and ns.Board.RefreshCamps)
	Run("borders", ns.Borders and ns.Borders.RefreshAll, true)
	Run("nameplates", ns.Nameplates and ns.Nameplates.RefreshAll, true)
	Run("chatmarks", ns.Borders and ns.Borders.ChatRefresh)
	ns.Fire("DATA_CHANGED")
	ns.Print(L.SETTINGS_RESET_DONE)
	Refresh()
end

local armedUntil = 0 -- the reset asks for a second click within this many seconds (no popup)
local ARM_SECONDS = 5

function Settings.Lines()
	local lines = {}
	local db = ns.db
	lines[#lines + 1] = { header = true, text = L.SETTINGS_DISPLAY }
	-- The window's width (UI.SetWidthStep): Normal, Wide, Wider, round again.
	if ns.UI.SetWidthStep and ns.UI.WIDTH_STEPS then
		local step = ns.UI.WidthStep()
		lines[#lines + 1] = {
			text = L.SETTINGS_WIDTH, right = Gold(L["SETTINGS_WIDTH_" .. step]), setting = "width",
			onClick = function() ns.UI.SetWidthStep(step % #ns.UI.WIDTH_STEPS + 1); Refresh() end,
			tooltip = function(tt)
				tt:AddLine(L.SETTINGS_WIDTH, 1, 0.82, 0)
				tt:AddLine(L.SETTINGS_WIDTH_TIP, 1, 1, 1, true)
			end,
		}
	end
	Toggle(lines, L.SETTINGS_MINIMAP, "/bk minimap", function() return not db.hideMinimap end,
		function() ns.db.hideMinimap = not ns.db.hideMinimap; ns.UI.UpdateMinimapButton() end)
	if ns.Positions then
		Toggle(lines, L.SETTINGS_MATES, "/bk mates", function() return db.showMates end, ns.Positions.SetEnabled)
		Toggle(lines, L.SETTINGS_SHARE, "/bk share", function() return db.sharePosition end, ns.Positions.SetSharing)
	end
	if ns.Board and ns.Board.SetCampsShown then
		Toggle(lines, L.SETTINGS_CAMPS, "/bk camps", function() return db.showCamps ~= false end, ns.Board.SetCampsShown)
	end
	if ns.Borders then
		Toggle(lines, L.SETTINGS_BORDERS, "/bk borders", ns.Borders.Enabled, ns.Borders.SetEnabled)
		Toggle(lines, L.SETTINGS_CHATMARKS, "/bk chatmarks", ns.Borders.ChatEnabled,
			function(on) ns.Borders.ChatSlash(on and "on" or "off") end)
	end
	if ns.Nameplates then
		Toggle(lines, L.SETTINGS_NAMEPLATES, "/bk nameplates", ns.Nameplates.Enabled, ns.Nameplates.SetEnabled)
	end
	if ns.Channels then
		Toggle(lines, L.SETTINGS_CHAT, "/bk chat", ns.Channels.ChatOn, ns.Channels.SetChatOn)
	end
	if ns.Bow then
		Toggle(lines, L.SETTINGS_BOW, "/bk bow", ns.Bow.Enabled, ns.Bow.SetEnabled)
	end
	if ns.Members and ns.Members.WarnDays then
		local days = ns.Members.WarnDays()
		lines[#lines + 1] = {
			text = L.SETTINGS_WARNDAYS, right = Gold(L.SETTINGS_DAYS:format(days)), setting = "/bk warndays",
			onClick = function() ns.Members.SetWarnDays(tostring(NextWarnDays(days))); Refresh() end,
			tooltip = function(tt)
				tt:AddLine(L.SETTINGS_WARNDAYS, 1, 0.82, 0)
				tt:AddLine(L.SETTINGS_CLICK:format("/bk warndays <1-60>"), 1, 1, 1, true)
			end,
		}
	end
	-- The alerts and their sounds: the Decrees tab's lines (Views.SoundLines).
	if ns.Views and ns.Views.SoundLines then ns.Views.SoundLines(lines) end
	lines[#lines].gapAfter = true
	if ns.Consent and ns.Consent.Show then
		lines[#lines + 1] = {
			header = true, text = L.SETTINGS_PRIVACY, setting = "/bk privacy",
			onClick = function() ns.Consent.Show() end,
			tooltip = function(tt)
				tt:AddLine(L.SETTINGS_PRIVACY, 1, 0.82, 0)
				tt:AddLine(L.SETTINGS_PRIVACY_TIP, 1, 1, 1, true)
			end,
			gapAfter = true,
		}
	end
	local armed = GetTime() < armedUntil
	lines[#lines + 1] = {
		header = true, text = armed and Red(L.SETTINGS_RESET_CONFIRM) or L.SETTINGS_RESET, setting = "reset",
		onClick = function()
			if GetTime() < armedUntil then armedUntil = 0; Settings.Reset()
			else armedUntil = GetTime() + ARM_SECONDS; Refresh() end
		end,
		tooltip = function(tt)
			tt:AddLine(L.SETTINGS_RESET, 1, 0.82, 0)
			tt:AddLine(L.SETTINGS_RESET_TIP, 1, 1, 1, true)
		end,
	}
	return lines, L.TAB_SETTINGS, L.SETTINGS_ABOUT
end

-- Everyone's tab, after the Poll's (UI.AddTab: before the window is built, so at load).
if ns.UI and ns.UI.AddTab then
	ns.UI.AddTab({ key = "settings", label = "TAB_SETTINGS", after = "poll",
		icon = "Interface\\Icons\\INV_Misc_Gear_01", build = Settings.Lines })
end
