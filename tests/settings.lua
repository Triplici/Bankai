-- The Settings tab (BankaiGuild/Settings.lua), on its own: `luajit tests/settings.lua`.
-- It loads the real file against small stand-ins for the parts it calls (each setter here only
-- records and writes ns.db, as the real ones do); the tab's look in game is an in-game check.
local ROOT = (debug.getinfo(1, "S").source:sub(2):match("^(.*)tests[/\\]settings%.lua$")) or "./"
local now = 100
GetTime = function() return now end

local calls, added = {}, nil
local function Rec(name) return function(...) calls[#calls + 1] = { name, ... } end end
local ns = {
	L = setmetatable({}, { __index = function(_, k) return k end }),
	db = { hideMinimap = true, showMates = true, sharePosition = true, showCamps = false, borders = false,
		nameplates = false, chatMarks = false, warnDays = 7, sound = false, soundOff = { arms = true },
		alertsAlways = true, addonChat = true, shareLocation = true },
	DEFAULTS = { hideMinimap = false, showMates = false, sharePosition = false, sound = true, showCamps = true, warnDays = 3 },
	SafeCall = function(_, fn, ...) return fn(...) end,
	Fire = Rec("Fire"), Print = Rec("Print"),
}
ns.UI = { AddTab = function(t) added = t; return true end, RefreshSoon = Rec("RefreshSoon"),
	UpdateMinimapButton = Rec("UpdateMinimapButton"), WIDTH_STEPS = { 0, 160, 320 },
	WidthStep = function() return ns.db.windowWidth or 1 end,
	SetWidthStep = function(i) ns.db.windowWidth = i ~= 1 and i or nil end }
ns.Positions = { SetEnabled = function(on) ns.db.showMates = on end, SetSharing = function(on) ns.db.sharePosition = on end,
	Refresh = Rec("Positions.Refresh") }
ns.Board = { SetCampsShown = function(on) ns.db.showCamps = on end, RefreshCamps = Rec("RefreshCamps") }
ns.Borders = { Enabled = function() return ns.db.borders ~= false end, SetEnabled = function(on) ns.db.borders = on end,
	ChatEnabled = function() return ns.db.chatMarks ~= false end, ChatSlash = function(w) ns.db.chatMarks = w == "on" end,
	RefreshAll = Rec("Borders.RefreshAll"), ChatRefresh = Rec("ChatRefresh") }
ns.Nameplates = { Enabled = function() return ns.db.nameplates ~= false end, SetEnabled = function(on) ns.db.nameplates = on end,
	RefreshAll = Rec("Nameplates.RefreshAll") }
ns.Channels = { ChatOn = function() return ns.db.addonChat == true end, SetChatOn = function(on) ns.db.addonChat = on end }
ns.Members = { WarnDays = function() return ns.db.warnDays end, SetWarnDays = function(t) ns.db.warnDays = tonumber(t) end }
ns.Consent = { Show = Rec("Consent.Show") }
ns.Bow = { Enabled = function() return ns.db.bowNudge ~= false end, SetEnabled = function(on) if on then ns.db.bowNudge = nil else ns.db.bowNudge = false end end }

assert(loadfile(ROOT .. "BankaiGuild/Settings.lua"))("BankaiGuild", ns)
local S = ns.Settings

-- The tab: everyone's, after the Poll's, built by Settings.Lines.
assert(added and added.key == "settings" and added.after == "poll" and added.label == "TAB_SETTINGS", "the tab is added")
assert(added.build == S.Lines)

local function Row(setting)
	for _, line in ipairs((S.Lines())) do if line.setting == setting then return line end end
	error("no line for " .. setting)
end

-- Each line runs its setter with the opposite of what it shows.
Row("/bk minimap").onClick(); assert(ns.db.hideMinimap == false, "minimap shown")
Row("width").onClick(); assert(ns.db.windowWidth == 2, "Wide")
Row("width").onClick(); assert(ns.db.windowWidth == 3, "Wider")
Row("/bk mates").onClick(); assert(ns.db.showMates == false)
Row("/bk camps").onClick(); assert(ns.db.showCamps == true)
Row("/bk borders").onClick(); assert(ns.db.borders == true)
Row("/bk chatmarks").onClick(); assert(ns.db.chatMarks == true)
Row("/bk nameplates").onClick(); assert(ns.db.nameplates == true)
Row("/bk chat").onClick(); assert(ns.db.addonChat == false)
Row("/bk bow").onClick(); assert(ns.db.bowNudge == false, "the /bow nudge off")
ns.db.addonChat = true

-- The absence days go 3, 7, 14, 30 and round again.
Row("/bk warndays").onClick(); assert(ns.db.warnDays == 14)
assert(S.NextWarnDays(30) == 3 and S.NextWarnDays(3) == 7 and S.NextWarnDays(5) == 7)

Row("/bk privacy").onClick(); assert(calls[#calls][1] == "Consent.Show", "privacy opens its page")

-- The reset: a first click only asks; a second within 5 seconds puts the defaults back, and
-- leaves the privacy answers and the chats alone.
ns.db.hideMinimap, ns.db.warnDays, ns.db.sound = true, 30, false
Row("reset").onClick()
assert(ns.db.hideMinimap == true and ns.db.warnDays == 30, "one click resets nothing")
assert(Row("reset").text:find("SETTINGS_RESET_CONFIRM", 1, true), "it asks for the second click")
now = now + 6
Row("reset").onClick()
assert(ns.db.hideMinimap == true, "a second click after 5 seconds only asks again")
now = now + 1
Row("reset").onClick()
assert(ns.db.hideMinimap == false and ns.db.warnDays == 3 and ns.db.sound == true and ns.db.showCamps == true)
assert(ns.db.borders == nil and ns.db.chatMarks == nil and ns.db.nameplates == nil and ns.db.soundOff == nil
	and ns.db.alertsAlways == nil and ns.db.bowNudge == nil and ns.db.windowWidth == nil and ns.db.showMates == false and ns.db.sharePosition == false)
assert(ns.db.addonChat == true and ns.db.shareLocation == true, "privacy answers and the chats are kept")
assert(ns.db.setupDue == true, "the setup page is due at the next load")
assert(not Row("reset").text:find("SETTINGS_RESET_CONFIRM", 1, true), "back to its label")

-- 11-05: with Bankai Guild's own chats off (Channels.Shown), the row is the linked guild chat's.
local linked = true
ns.Channels.Shown = function() return false end
ns.LinkedChat = { Enabled = function() return linked end, SetEnabled = function(on) linked = on end }
for _, line in ipairs((S.Lines())) do assert(line.setting ~= "/bk chat", "no row for the chats that are off") end
Row("/bk glink").onClick(); assert(linked == false, "the linked chat off")
Row("/bk glink").onClick(); assert(linked == true, "and on again")

print("settings: ok")
