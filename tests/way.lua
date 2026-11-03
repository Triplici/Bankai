-- The Way of the Grove (BankaiGuild/ChurchView.lua's charter page) and the /bow nudge (Bow.lua), on
-- their own: `luajit tests/way.lua`. Each file is loaded against small stand-ins for what it calls;
-- how the page looks in game is an in-game check.
local ROOT = (debug.getinfo(1, "S").source:sub(2):match("^(.*)tests[/\\]way%.lua$")) or "./"
local now, printed = 100, {}
GetTime = function() return now end
UnitGUID = function() return "Player-1-AAAA" end
local guild, rank = "ELFCORE", "Ranger"
GetGuildInfo = function() return guild, rank, 6 end

local function NS()
	return { L = setmetatable({}, { __index = function(_, k) return k end }), db = {},
		Print = function(m) printed[#printed + 1] = m end, SafeCall = function(_, fn, ...) return fn(...) end,
		RegisterEvent = function() end, On = function() end, IsMember = function() return true end,
		Codec = { Plain = function(s) return s end }, Church = {}, ChurchCount = {} }
end

-- The /bow nudge: our own killing blow on a player, once per 30 seconds, on unless turned off.
local ns = NS()
assert(loadfile(ROOT .. "BankaiGuild/Bow.lua"))("BankaiGuild", ns)
local Bow = ns.Bow
assert(Bow.Enabled(), "on by default")
assert(Bow.OnPartyKill("Player-1-AAAA", "Player-1-BBBB") and printed[#printed] == "BOW_NUDGE", "our kill of a player")
now = now + 5
assert(not Bow.OnPartyKill("Player-1-AAAA", "Player-1-CCCC"), "a second kill in the same fight says nothing")
now = now + 30
assert(not Bow.OnPartyKill("Player-1-AAAA", "Creature-0-1-2-3-4-5"), "a creature is no PvP kill")
assert(not Bow.OnPartyKill("Player-1-DDDD", "Player-1-BBBB"), "a groupmate's killing blow is his")
assert(Bow.OnPartyKill("Player-1-AAAA", "Player-1-BBBB"), "after the gap, again")
Bow.SetEnabled(false); now = now + 60
assert(ns.db.bowNudge == false and not Bow.Enabled() and not Bow.OnPartyKill("Player-1-AAAA", "Player-1-BBBB"), "off")
Bow.SetEnabled(true)
assert(ns.db.bowNudge == nil and Bow.Enabled(), "on again, back to the default")

-- The charter page: a guild with "core" in its name reads ELFCORE's ladder, every other BANKAI's.
ns = NS()
assert(loadfile(ROOT .. "BankaiGuild/ChurchView.lua"))("BankaiGuild", ns)
local V = ns.ChurchView or ns.Church.View
assert(V and V.LadderFor and V.WayLines, "the page's functions")
assert(V.LadderFor("ELFCORE") == V.RANKS.core and V.LadderFor("Nightcore") == V.RANKS.core and V.LadderFor("Elunecore II") == V.RANKS.core)
assert(V.LadderFor("BANKAI") == V.RANKS.bankai and V.LadderFor("Anything Else") == V.RANKS.bankai and V.LadderFor(nil) == V.RANKS.bankai)
for _, ladder in pairs(V.RANKS) do assert(#ladder == 9, "nine ranks each") end

local function Marked(lines)
	for _, l in ipairs(lines) do if l.right then return l.text end end
end
local lines, title, detail = V.WayLines()
assert(title == "CHURCH_TITLE" and detail == "WAY_DETAIL")
assert(Marked(lines):find("Ranger", 1, true), "an ELFCORE Ranger sees his rank marked")
guild, rank = "BANKAI", "Ronin"
assert(Marked(V.WayLines()):find("Ronin", 1, true), "a BANKAI Ronin sees his")
rank = "Custom Rank"
assert(Marked(V.WayLines()) == nil, "a rank of the guild's own naming marks nothing")

-- Long text goes over rows of the width at most, no word lost.
local rows = V.Wrap("one two three four five six seven", 10)
assert(table.concat(rows, " ") == "one two three four five six seven")
for _, r in ipairs(rows) do assert(#r <= 10, r) end

print("way: ok")
