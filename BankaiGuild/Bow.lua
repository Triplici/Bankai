local ADDON, ns = ...
local L = ns.L

-- The /bow nudge (11-02, the guild charter's "Honor in combat: follow kills with a /bow whenever
-- possible!"): our own killing blow on a player puts one reminder line in chat. On by default;
-- /bk bow or the Settings tab turns it off (ns.db.bowNudge false). It never bows for the player
-- and sends nothing. The kill is the client's native PARTY_KILL, as The Wanted reads it
-- (Wanted.lua: the combat log itself is restricted on Forever).
local Bow = {}
ns.Bow = Bow

Bow.GAP = 30 -- seconds between two reminders (a fight with several kills says it once)
local last = -math.huge

local function Secret(v) return type(issecretvalue) == "function" and issecretvalue(v) == true end

function Bow.Enabled() return not (ns.db and ns.db.bowNudge == false) end

function Bow.SetEnabled(on)
	if on then ns.db.bowNudge = nil else ns.db.bowNudge = false end -- (nil: on, the default)
	ns.Print(on and L.BOW_ON or L.BOW_OFF)
end

-- attacker and target: PARTY_KILL's GUIDs. True when the line was shown.
function Bow.OnPartyKill(attacker, target)
	if not Bow.Enabled() or Secret(attacker) or Secret(target) then return false end
	if type(attacker) ~= "string" or type(target) ~= "string" or not target:find("^Player%-") then return false end
	local me = UnitGUID and UnitGUID("player")
	if Secret(me) or attacker ~= me then return false end
	local now = GetTime()
	if now - last < Bow.GAP then return false end
	last = now
	ns.Print(L.BOW_NUDGE)
	return true
end
function Bow.Reset() last = -math.huge end -- (tests)

-- (pcall: a client without PARTY_KILL must not stop the login, as in Wanted.lua.)
pcall(ns.RegisterEvent, "PARTY_KILL", function(attacker, target) ns.SafeCall("bow", Bow.OnPartyKill, attacker, target) end)
