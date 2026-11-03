-- The honor boards (BankaiGuild/Honor.lua), on their own: `luajit tests/honor.lua`. The real file
-- is loaded against small stand-ins for what it calls (Comm records what would go out).
local ROOT = (debug.getinfo(1, "S").source:sub(2):match("^(.*)tests[/\\]honor%.lua$")) or "./"
local clock, server = 100, 7 * 86400 * 3000 + 3600 -- (a Monday-ish hour, far from a week's edge)
GetTime = function() return clock end
issecretvalue = nil

local sent, printed, handler, emote = {}, {}, nil, nil
local ns = {
	L = setmetatable({}, { __index = function(_, k) return k end }), rdb = {}, me = "Trip-Realm", realm = "Realm",
	Print = function(m) printed[#printed + 1] = m end, Fire = function() end, IsMember = function() return true end,
	SafeCall = function(_, fn, ...) return fn(...) end,
	RegisterEvent = function(e, fn) if e == "CHAT_MSG_TEXT_EMOTE" then emote = fn end end,
	Fold = function(s) return s:lower() end,
	ShortName = function(n) return n and (n:gsub("%-.*$", "")) end,
	FullName = function(n) if not n or n:find("-", 1, true) then return n end return n .. "-Realm" end,
	DisplayName = function(n) return (n:gsub("%-Realm$", "")) end,
	Comm = { Send = function(dist, msg) sent[#sent + 1] = dist .. " " .. msg end, Handle = function(t, fn) assert(t == "HB"); handler = fn end },
	Bow = { killAt = -math.huge },
}
assert(loadfile(ROOT .. "BankaiGuild/Honor.lua"))("BankaiGuild", ns)
local H = ns.Honor
H.now = function() return server end
assert(handler and emote, "the HB type and the emote listener are registered")

-- Kudos: one per player a day, KUDOS_PER_DAY players a day, never oneself; told on the channel.
assert(H.Thank("twee") == true and sent[#sent] == "CHANNEL HB~K~Twee-Realm", "a kudo goes out")
assert(not H.Thank("Twee"), "the same player twice in a day")
assert(not H.Thank("Trip"), "never oneself")
for i = 1, H.KUDOS_PER_DAY - 1 do assert(H.Thank("Friend" .. i), i) end
assert(not H.Thank("OneTooMany"), "the day's limit")
server = server + 86400
assert(H.Thank("Twee"), "a new day, a new kudo")
assert(H.Top("kudos")[1].name == "Twee-Realm" and H.Top("kudos")[1].n == 2)

-- Heard from others: on the channel only, the sender's own name, the same rules.
assert(handler("CHANNEL", "Twee-Realm", "HB~K~Trip-Realm"))
assert(not handler("CHANNEL", "Twee-Realm", "HB~K~Trip-Realm"), "his second kudo to me today")
assert(not handler("GUILD", "Other-Realm", "HB~K~Trip-Realm"), "never over GUILD")
assert(not handler("CHANNEL", "Other-Realm", "HB~K~Other-Realm"), "never himself")
assert(not handler("CHANNEL", "Other-Realm", "HB~K~not a name"), "a name with a realm")

-- Bows: within a minute of our own killing blow on a player, once, 30 s apart, 20 a week.
assert(not H.OnTextEmote("You bow before Enemy.", "Trip"), "no kill: no bow counted")
ns.Bow.killAt = clock - 10
assert(not H.OnTextEmote("Twee bows before you.", "Twee"), "another's emote")
assert(H.OnTextEmote("You bow before Enemy.", "Trip") and sent[#sent] == "CHANNEL HB~B~", "our bow after the kill")
assert(ns.Bow.killAt == -math.huge, "one bow a kill")
ns.Bow.killAt = clock - 61
assert(not H.OnTextEmote("You bow before Enemy.", "Trip"), "past the minute")
assert(handler("CHANNEL", "Twee-Realm", "HB~B~"))
assert(not handler("CHANNEL", "Twee-Realm", "HB~B~"), "30 s apart")
server = server + 31
assert(handler("CHANNEL", "Twee-Realm", "HB~B~"))
assert(H.Top("bows")[1].name == "Twee-Realm" and H.Top("bows")[1].n == 2)

-- A new week starts the boards again.
server = server + 7 * 86400
assert(#H.Top("kudos") == 0 and #H.Top("bows") == 0, "a new week")

-- The page's lines: both boards, and how to give one.
local lines = {}
H.Lines(lines, function(s) return s end, function(s) return s end)
assert(lines[1].text == "KUDOS_TITLE" and lines[2].text == "KUDOS_EMPTY" and lines[#lines].text == "KUDOS_HOW")

print("honor: ok")
