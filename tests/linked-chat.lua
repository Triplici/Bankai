-- The linked guild chat (BankaiGuild/LinkedChat.lua: Twee's Guild Link, ported), on its own:
-- `luajit tests/linked-chat.lua`. The real file is loaded against small stand-ins for the game's
-- chat: channels joined by name, what is sent to them, the chat windows' lines.
local ROOT = (debug.getinfo(1, "S").source:sub(2):match("^(.*)tests[/\\]linked%-chat%.lua$")) or "./"
local clock = 100
GetTime = function() return clock end
InCombatLockdown = function() return false end
issecretvalue = nil

local hooks, joined, left, sent, filters = {}, {}, {}, {}, {}
hooksecurefunc = function(a, b, c)
	if type(a) == "string" then hooks[a] = b else hooks["C_ChatInfo." .. b] = c end
end
SendChatMessage = function(text, chatType, _, idx) sent[#sent + 1] = { text = text, chatType = chatType, idx = idx } end
C_ChatInfo = { SendChatMessage = SendChatMessage }
local channels = {} -- name (lower) -> index
GetChannelName = function(name) return channels[name:lower()] or 0 end
JoinChannelByName = function(name, password) joined[#joined + 1] = name .. "/" .. password; channels[name:lower()] = 5 + #joined end
LeaveChannelByName = function(name) left[#left + 1] = name; channels[name:lower()] = nil end
ChatFrame_AddMessageEventFilter = function(event, fn) filters[event] = fn end
local function Frame(types)
	return { messageTypeList = types, channelList = {}, lines = {}, AddMessage = function(self, line) self.lines[#self.lines + 1] = line end }
end
ChatFrame1, ChatFrame2 = Frame({ "SAY", "GUILD" }), Frame({ "OFFICER" })
DEFAULT_CHAT_FRAME, NUM_CHAT_WINDOWS = ChatFrame1, 2
ChatFrame_RemoveChannel = function(f, n)
	for i = #f.channelList, 1, -1 do if f.channelList[i] == n then table.remove(f.channelList, i) end end
end
local guildInfo, rank = "Our guild's rules.\nGLink:bankailink:sekret:BNK", 4
IsInGuild = function() return true end
GetGuildInfo = function() return "Bankai", "Rank", rank end
GetGuildInfoText = function() return guildInfo end
GetNumGuildMembers = function() return 2 end
local roster = { { "Mate One-Realm", "g-mate1" }, { "Trip Trip-Realm", "g-me" } }
GetGuildRosterInfo = function(i) local r = roster[i]; return r[1], nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, r[2] end
UnitGUID = function() return "g-me" end
local loaded = {}
C_AddOns = { IsAddOnLoaded = function(name) return loaded[name] == true end }
GUILD, OFFICER = "Guild", "Officer"
ChatTypeInfo = { GUILD = { r = 0.25, g = 1, b = 0.25 }, OFFICER = { r = 0.25, g = 0.75, b = 0.25 } }

local on, events, printed = {}, {}, {}
local ns = {
	L = setmetatable({ GLINK_GUILD = "Guild", GLINK_OFFICER = "Officer" }, { __index = function(_, k) return k end }), db = {}, me = "Trip Trip-Realm", COUNCIL_MEMBER_RANK = 2,
	Gate = { Allowed = function() return true end },
	SafeCall = function(_, fn, ...) return fn(...) end,
	On = function(name, fn) on[name] = fn end,
	RegisterEvent = function(event, fn) events[event] = fn end,
	Every = function() end, After = function() end,
	Print = function(m) printed[#printed + 1] = m end,
	Roster = { MyRank = function() return rank end },
}
assert(loadfile(ROOT .. "BankaiGuild/LinkedChat.lua"))("BankaiGuild", ns)
local LC = ns.LinkedChat
local function eq(a, b, m) if a ~= b then error((m or "") .. " expected " .. tostring(b) .. ", got " .. tostring(a), 2) end end

assert(hooks.SendChatMessage and hooks["C_ChatInfo.SendChatMessage"], "post-hooks on both sends")

-- The Guild Info line: with a password, without one, and a TAG made from the guild's name.
local c = LC.Parse("x\nGLink:chan:pw:ABC\ny", "Bankai")
eq(c.channel, "chan"); eq(c.password, "pw"); eq(c.tag, "ABC")
c = LC.Parse("GLink: chan : ABC ", "Bankai"); eq(c.password, ""); eq(c.tag, "ABC")
c = LC.Parse("glink:chan", "Elfcore Two"); eq(c.tag, "ELFC")
eq(LC.Parse("no line here", "Bankai"), nil)

-- Login: the line read, the guild channel joined (a member: no officers' channel), its raw lines filtered.
on.LOGIN()
eq(joined[1], "bankailink/sekret"); eq(#joined, 1, "a member joins the guild channel alone")
assert(filters.CHAT_MSG_CHANNEL, "the raw lines' filter")

-- Our /g goes to the channel with our TAG; /say does not; /o does not for a member.
hooks.SendChatMessage("hello all", "GUILD")
eq(#sent, 1); eq(sent[1].text, "[BNK] hello all"); eq(sent[1].chatType, "CHANNEL"); eq(sent[1].idx, 6)
hooks["C_ChatInfo.SendChatMessage"]("hello all", "GUILD")
eq(#sent, 1, "the second hook for the same send posts nothing")
hooks.SendChatMessage("hi", "SAY"); hooks.SendChatMessage("officers only", "OFFICER")
eq(#sent, 1, "neither a /say nor a member's /o")
-- A long line goes in pieces, each under the cap with its TAG.
clock = clock + 1
hooks.SendChatMessage(("x"):rep(400), "GUILD")
eq(#sent, 3); assert(#sent[2].text <= LC.MAXPOST and #sent[3].text <= LC.MAXPOST and sent[3].text:find("^%[BNK%] "))

-- Another guild's line shows in the guild chat window as the game's own; ours and a guildmate's never.
eq(events.CHAT_MSG_CHANNEL("[ELF] raid at 8", "Leaf Walker-Realm", nil, "6. bankailink", nil, nil, nil, nil, "bankailink", nil, nil, "g-other"), true)
eq(#ChatFrame1.lines, 1); assert(ChatFrame1.lines[1]:find("^|Hchannel:GUILD|h%[Guild%]|h |Hplayer:Leaf Walker%-Realm|h%[Leaf Walker%-Realm%]|h: %[ELF%] raid at 8$"), ChatFrame1.lines[1])
eq(events.CHAT_MSG_CHANNEL("[BNK] hello all", "Trip Trip-Realm", nil, "", nil, nil, nil, nil, "bankailink", nil, nil, "g-me"), false, "our own")
eq(events.CHAT_MSG_CHANNEL("[BNK] hi", "Mate One-Realm", nil, "", nil, nil, nil, nil, "bankailink", nil, nil, "g-mate1"), false, "a guildmate's")
eq(events.CHAT_MSG_CHANNEL("[ELF] hi", "Leaf Walker-Realm", nil, "", nil, nil, nil, nil, "Trade", nil, nil, "g-other"), false, "another channel")
eq(filters.CHAT_MSG_CHANNEL(nil, nil, nil, nil, nil, "6. bankailink", nil, nil, nil, nil, "bankailink"), true, "its raw line filtered")
eq(filters.CHAT_MSG_CHANNEL(nil, nil, nil, nil, nil, "2. Trade", nil, nil, nil, nil, "Trade"), false)

-- An officer (rank 2 and up) joins the officers' channel too; his /o goes there, and others' /o
-- show in his officer chat window.
rank = 2
LC.Ensure()
eq(joined[#joined], "bankailinko/sekret")
hooks.SendChatMessage("officer plans", "OFFICER")
eq(sent[#sent].text, "[BNK] officer plans"); eq(sent[#sent].idx, 7)
eq(events.CHAT_MSG_CHANNEL("[ELF] officers too", "Leaf Walker-Realm", nil, "", nil, nil, nil, nil, "bankailinko", nil, nil, "g-other"), true)
assert(ChatFrame2.lines[1]:find("^|Hchannel:OFFICER|h%[Officer%]|h "), ChatFrame2.lines[1])
-- No longer an officer: he leaves it.
rank = 4
LC.Ensure()
eq(left[#left], "bankailinko")

-- A new line in Guild Info: the old channel left, the new one joined.
guildInfo = "GLink:newlink:BNK"
LC.Read()
eq(left[#left], "bankailink"); eq(joined[#joined], "newlink/")

-- Guild Link itself installed: Bankai Guild stands down, nothing posted.
loaded.GuildLink = true
local before = #sent
hooks.SendChatMessage("twice?", "GUILD")
eq(#sent, before, "Guild Link relays, not us")
loaded.GuildLink = nil

-- /bk glink off: nothing relayed, its channels left; on again.
LC.Slash("off")
hooks.SendChatMessage("off now", "GUILD")
eq(#sent, before); eq(left[#left], "newlink")
LC.Slash("on")
eq(joined[#joined], "newlink/")

print("linked-chat: ok")
