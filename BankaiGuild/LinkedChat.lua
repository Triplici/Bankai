local ADDON, ns = ...
local L = ns.L

-- Linked chat (11-05, the owner's call): Bankai Guild's chat is the guilds' own guild chat, linked
-- across every allied guild the way Twee's Guild Link (GuildLink 1.0.2) does it, ported here so
-- one addon does it all. Bankai Guild's own [Bankai Guild] and [Council] chats are off meanwhile
-- (Channels.Shown: ns.BANKAI_CHAT_SHOWN).
--
-- Setup, officers, one line in Guild Info of each allied guild (the same channel and password in
-- all of them, each guild its own short TAG; the password may be left out):
--   GLink:<channel>:<password>:<TAG>        GLink:<channel>:<TAG>
-- Then:
--   * Every member joins <channel> by himself (JoinChannelByName), and every officer (rank
--     ns.COUNCIL_MEMBER_RANK or higher) also <channel>o, the officers' channel, with the same password.
--   * A line he sends to /g also goes to <channel> as "[TAG] line"; one to /o, to <channel>o.
--   * Other guilds' lines show in his guild (or officer) chat windows as the game's own would:
--     [Guild] [Name]: [TAG] line. His own and his guildmates' are skipped: he saw them already.
--   * The channels stay off his chat windows' lists (he is still in them), and their raw lines are
--     filtered out of the windows that would show them anyway.
-- Not private: anyone who joins the channel by its name and password reads it, and Guild Info shows
-- both to every member. The officers' channel is the same with an "o": the addon only keeps it off
-- the members' screens.
-- With Guild Link itself installed this file stands down (two relays would post every line twice).
-- Custom channels are per realm (connected realms only), as Bankai Guild's own network is.

local LinkedChat = {}
ns.LinkedChat = LinkedChat

LinkedChat.MAXPOST = 250  -- bytes a channel post (Guild Link's; not yet confirmed on Forever)
LinkedChat.TICK = 30      -- seconds between housekeeping checks
LinkedChat.OFFICER_SUFFIX = "o"

local S = { cfg = {}, wanted = {}, rosterBase = {}, rosterGUID = {}, lastPostTry = nil, lastRecv = nil, lastRecvFrom = nil }
LinkedChat.state = S -- (tests)

local function Secret(v) return type(issecretvalue) == "function" and issecretvalue(v) == true end
local function Plain(v) if Secret(v) then return nil end return v end
local function InCombat() return InCombatLockdown ~= nil and InCombatLockdown() end
local function Trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
local function Now() return GetTime() end

local function DB()
	if not ns.db then return nil end
	ns.db.linkedChat = type(ns.db.linkedChat) == "table" and ns.db.linkedChat or {}
	local d = ns.db.linkedChat
	if d.enabled == nil then d.enabled = true end
	if d.hideChannel == nil then d.hideChannel = true end
	return d
end
local function CharDB()
	local d = DB()
	if not d or not ns.me then return nil end
	d.chars = type(d.chars) == "table" and d.chars or {}
	d.chars[ns.me] = type(d.chars[ns.me]) == "table" and d.chars[ns.me] or {}
	return d.chars[ns.me]
end

-- Guild Link itself installed: it relays, this file does not.
function LinkedChat.StandsDown()
	local AO = C_AddOns
	local fn = (type(AO) == "table" and AO.IsAddOnLoaded) or IsAddOnLoaded
	if type(fn) ~= "function" then return false end
	local ok, loaded = pcall(fn, "GuildLink")
	return ok and loaded == true
end

local function MyGuild() return IsInGuild and IsInGuild() and GetGuildInfo("player") or nil end
local function Officer()
	local R = ns.Roster
	local rank = R and type(R.MyRank) == "function" and R.MyRank() or nil
	return type(rank) == "number" and rank <= (ns.COUNCIL_MEMBER_RANK or 1)
end

-- The channels this character relays: { guild = name, officer = name or nil }.
function LinkedChat.Channels()
	local c = S.cfg.channel
	if not c then return {} end
	return { guild = c, officer = Officer() and (c .. LinkedChat.OFFICER_SUFFIX) or nil }
end

function LinkedChat.Configured()
	local d = DB()
	return d ~= nil and d.enabled == true and S.cfg.channel ~= nil and MyGuild() ~= nil and not LinkedChat.StandsDown()
end

---------------------------------------------------------------------------
-- The Guild Info line
---------------------------------------------------------------------------

-- "GLink:<channel>:<password>:<TAG>" or "GLink:<channel>:<TAG>": { channel, password, tag } or nil.
function LinkedChat.Parse(text, guild)
	if type(text) ~= "string" or Secret(text) then return nil end
	local cfg
	for line in text:gmatch("[^\r\n]+") do
		line = Trim(line)
		if line:lower():sub(1, 6) == "glink:" then
			local parts = {}
			for p in (line:sub(7) .. ":"):gmatch("([^:]*):") do parts[#parts + 1] = Trim(p) end
			if parts[1] and parts[1] ~= "" then
				cfg = { channel = parts[1], password = "" }
				if parts[3] and parts[3] ~= "" then
					cfg.password, cfg.tag = parts[2] or "", parts[3]
				elseif parts[2] and parts[2] ~= "" then
					cfg.tag = parts[2]
				end
			end
		end
	end
	if not cfg then return nil end
	cfg.tag = cfg.tag or tostring(guild or "GUILD"):gsub("[^%w]", ""):sub(1, 4):upper()
	cfg.tag = cfg.tag:gsub("[%s%[%]\t:]", "")
	if cfg.tag == "" then cfg.tag = "GUILD" end
	return cfg
end

---------------------------------------------------------------------------
-- The channels: joined, left, kept off the chat windows' lists
---------------------------------------------------------------------------

local function Index(name)
	if not name or type(GetChannelName) ~= "function" then return nil end
	local ok, idx = pcall(GetChannelName, name) -- gp:linked-chat
	if ok and type(idx) == "number" and idx > 0 then return idx end
	return nil
end

-- "linked" or "3. linked", however a window names it: one of ours? "guild", "officer" or nil.
function LinkedChat.Which(name)
	if type(name) ~= "string" or Secret(name) then return nil end
	name = name:lower():gsub("^%d+%.%s*", "")
	local ch = LinkedChat.Channels()
	if ch.guild and name == ch.guild:lower() then return "guild" end
	if ch.officer and name == ch.officer:lower() then return "officer" end
	return nil
end

local function Join(name)
	if not name or Index(name) or type(JoinChannelByName) ~= "function" then return end -- gp:linked-chat
	if InCombat() then return end -- (the next tick, or the end of combat, tries again)
	pcall(JoinChannelByName, name, S.cfg.password or "") -- gp:linked-chat
end
local function Leave(name)
	if name and Index(name) and type(LeaveChannelByName) == "function" then pcall(LeaveChannelByName, name) end -- gp:linked-chat
end

local function ChatFrames(chatType)
	local list = {}
	for i = 1, (NUM_CHAT_WINDOWS or 10) do
		local f = _G["ChatFrame" .. i] -- gp:linked-chat
		if f and type(f.messageTypeList) == "table" then
			for _, g in ipairs(f.messageTypeList) do
				if g == chatType then list[#list + 1] = f; break end
			end
		end
	end
	if #list == 0 and DEFAULT_CHAT_FRAME then list[1] = DEFAULT_CHAT_FRAME end -- gp:linked-chat
	return list
end

local function Unlist()
	local d = DB()
	if not d or not d.hideChannel or InCombat() then return end
	for i = 1, (NUM_CHAT_WINDOWS or 10) do
		local f = _G["ChatFrame" .. i] -- gp:linked-chat
		if f and type(f.channelList) == "table" then
			for j = #f.channelList, 1, -1 do
				local n = f.channelList[j]
				if LinkedChat.Which(n) and type(ChatFrame_RemoveChannel) == "function" then pcall(ChatFrame_RemoveChannel, f, n) end -- gp:linked-chat
			end
		end
	end
end

-- Join what this character relays, leave what it no longer does (a new channel in Guild Info, an
-- officer no longer one).
function LinkedChat.Ensure()
	local want = LinkedChat.Configured() and LinkedChat.Channels() or {}
	for _, kind in ipairs({ "guild", "officer" }) do
		local old, new = S.wanted[kind], want[kind]
		if old and old ~= new then Leave(old) end
		S.wanted[kind] = new
		if new then Join(new) end
	end
	Unlist()
end

function LinkedChat.Read()
	if InCombat() then return end -- (Guild Info can't be read in combat: the next tick reads it)
	-- (GetGuildInfoText: Guild Link reads Guild Info with it on Forever; the offline model's list of the
	-- client's functions, tests/fixtures/forever-api.lua, has never seen it, so it is looked up without
	-- assuming it: a client without it leaves the linked chat off, never an error.)
	local read = rawget(_G, "GetGuildInfoText") -- gp:linked-chat
	if type(read) ~= "function" then return end
	local ok, text = pcall(read) -- gp:linked-chat
	if not ok or type(text) ~= "string" or Secret(text) then return end
	if text == "" then return end -- (not loaded yet right after login)
	local cfg = LinkedChat.Parse(text, MyGuild())
	S.cfg = cfg or {}
	local c = CharDB()
	if c then c.cache = cfg and { channel = cfg.channel, password = cfg.password, tag = cfg.tag, guild = MyGuild() } or nil end
	LinkedChat.Ensure()
end

---------------------------------------------------------------------------
-- Sending: our own /g and /o lines, as we send them
---------------------------------------------------------------------------

local function Split(s, max)
	local out = {}
	while #s > max do
		local cut = max
		while cut > 1 do
			local b = s:byte(cut + 1)
			if b and b >= 0x80 and b < 0xC0 then cut = cut - 1 else break end
		end
		out[#out + 1] = s:sub(1, cut)
		s = s:sub(cut + 1)
	end
	out[#out + 1] = s
	return out
end

local function Post(channel, text)
	local idx = Index(channel)
	if not idx then Join(channel) return false end
	S.lastPostTry = Now() -- (first: the game can hand our own post back during the send)
	local head = "[" .. S.cfg.tag .. "] "
	for _, part in ipairs(Split(text, LinkedChat.MAXPOST - #head)) do
		pcall(SendChatMessage, head .. part, "CHANNEL", nil, idx) -- gp:linked-chat
	end
	return true
end

local lastOwn, lastOwnAt = nil, 0
-- The post-hook's work: true when the line went to a linked channel.
function LinkedChat.OnOwnSend(msg, chatType)
	if type(chatType) ~= "string" or Secret(chatType) or type(msg) ~= "string" or Secret(msg) or msg == "" then return false end
	local kind = chatType:upper() == "GUILD" and "guild" or (chatType:upper() == "OFFICER" and "officer") or nil
	if not kind or not LinkedChat.Configured() then return false end
	local channel = LinkedChat.Channels()[kind]
	if not channel then return false end
	if msg == lastOwn and Now() - lastOwnAt < 0.5 then return false end -- (both hooks for one send)
	lastOwn, lastOwnAt = msg, Now()
	return Post(channel, msg)
end

---------------------------------------------------------------------------
-- Showing: other guilds' lines, in the guild (or officer) chat windows
---------------------------------------------------------------------------

local function IsGuildmate(name, guid)
	guid = Plain(guid)
	if type(guid) == "string" and guid ~= "" and S.rosterGUID[guid] then return true end
	name = Plain(name)
	local base = type(name) == "string" and Trim(name:match("^([^%-]+)") or ""):lower() or ""
	return base ~= "" and S.rosterBase[base] == true
end

local CHAT = { guild = "GUILD", officer = "OFFICER" }
local LABEL = { guild = function() return L.GLINK_GUILD end, officer = function() return L.GLINK_OFFICER end }

local function ClassHex(guid)
	if type(guid) ~= "string" or guid == "" or type(GetPlayerInfoByGUID) ~= "function" then return nil end
	local ok, _, file = pcall(GetPlayerInfoByGUID, guid)
	if not ok or type(file) ~= "string" or Secret(file) or file == "" then return nil end
	local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[file]
	if not c then return nil end
	if c.GenerateHexColor then return c:GenerateHexColor() end
	return c.colorStr or ("ff%02x%02x%02x"):format(c.r * 255, c.g * 255, c.b * 255)
end

-- The line as the game shows its own guild chat: [Guild] [Name]: text.
function LinkedChat.Format(kind, text, author, guid)
	local who = "[?]"
	if type(author) == "string" and not Secret(author) then
		local hex = ClassHex(guid)
		who = ("|Hplayer:%s|h[%s]|h"):format(author, hex and ("|c" .. hex .. author .. "|r") or author)
	end
	return "|Hchannel:" .. CHAT[kind] .. "|h[" .. LABEL[kind]() .. "]|h " .. who .. ": " .. text
end

-- CHAT_MSG_CHANNEL's handler: true when the line was shown.
function LinkedChat.OnChannel(text, sender, _, channelName, _, _, _, _, channelBaseName, _, _, guid)
	if not LinkedChat.Configured() then return false end
	local kind = LinkedChat.Which(channelBaseName) or LinkedChat.Which(channelName)
	if not kind then return false end
	local content, author, authorGUID = Plain(text), Plain(sender), Plain(guid)
	if content == nil then return false end
	local me = UnitGUID and UnitGUID("player")
	if authorGUID and not Secret(me) and authorGUID == me then return false end
	if IsGuildmate(author, authorGUID) then return false end
	if not author and S.lastPostTry and Now() - S.lastPostTry < 3 then return false end -- (probably ours)
	S.lastRecv, S.lastRecvFrom = Now(), author
	local c = (ChatTypeInfo and ChatTypeInfo[CHAT[kind]]) or { r = 0.25, g = 1, b = 0.25 }
	local line = LinkedChat.Format(kind, content, author, authorGUID)
	for _, f in ipairs(ChatFrames(CHAT[kind])) do f:AddMessage(line, c.r, c.g, c.b) end -- gp:linked-chat
	return true
end

-- The channels' own raw lines, out of the windows that still list them (the game's chat filter).
function LinkedChat.Filter(_, _, _, _, _, channelName, _, _, _, _, channelBaseName)
	if not ns.Gate.Allowed("system-filters") then return false end
	local d = DB()
	if not d or not d.hideChannel or not LinkedChat.Configured() then return false end
	return (LinkedChat.Which(channelBaseName) or LinkedChat.Which(channelName)) ~= nil
end

local function Roster()
	if InCombat() or type(GetNumGuildMembers) ~= "function" then return end
	local n = GetNumGuildMembers() or 0
	if n == 0 then return end
	local base, guids = {}, {}
	for i = 1, n do
		local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
		name = Plain(name)
		if type(name) == "string" then
			local b = Trim(name:match("^([^%-]+)") or ""):lower()
			if b ~= "" then base[b] = true end
		end
		guid = Plain(guid)
		if type(guid) == "string" and guid ~= "" then guids[guid] = true end
	end
	S.rosterBase, S.rosterGUID = base, guids
end

---------------------------------------------------------------------------
-- /bk glink
---------------------------------------------------------------------------

function LinkedChat.StatusLines()
	local out = {}
	local d = DB()
	if LinkedChat.StandsDown() then out[1] = L.GLINK_STANDS_DOWN return out end
	out[#out + 1] = d and d.enabled and L.GLINK_ON or L.GLINK_OFF
	if not MyGuild() then out[#out + 1] = L.GLINK_NO_GUILD return out end
	if not S.cfg.channel then out[#out + 1] = L.GLINK_NO_LINE return out end
	local ch = LinkedChat.Channels()
	out[#out + 1] = L.GLINK_CHANNEL:format(S.cfg.tag, ch.guild, Index(ch.guild) and L.GLINK_IN or L.GLINK_NOT_IN)
	if ch.officer then out[#out + 1] = L.GLINK_OFFICERS:format(ch.officer, Index(ch.officer) and L.GLINK_IN or L.GLINK_NOT_IN) end
	out[#out + 1] = S.lastRecv and L.GLINK_LAST:format(math.floor(Now() - S.lastRecv)) or L.GLINK_LAST_NEVER
	return out
end

function LinkedChat.Enabled() local d = DB() return d ~= nil and d.enabled == true end
function LinkedChat.SetEnabled(on) LinkedChat.Slash(on and "on" or "off") end

function LinkedChat.Slash(rest)
	local w = tostring(rest or ""):lower():match("^%s*(%S*)")
	local d = DB()
	if w == "on" or w == "off" then
		d.enabled = w == "on"
		if not d.enabled then for _, n in pairs(S.wanted) do Leave(n) end S.wanted = {} end
		LinkedChat.Read()
	elseif w == "rejoin" or w == "rescan" then
		S.wanted = {}
		LinkedChat.Read()
	elseif w == "showchan" then
		d.hideChannel = not d.hideChannel
		Unlist()
	end
	for _, line in ipairs(LinkedChat.StatusLines()) do ns.Print(line) end
end

---------------------------------------------------------------------------
-- The hooks and events
---------------------------------------------------------------------------

-- Post-hooks (hooksecurefunc keeps the game's send its own): they read what the player sent.
if type(hooksecurefunc) == "function" then -- gp:linked-chat
	if type(SendChatMessage) == "function" then -- gp:linked-chat
		hooksecurefunc("SendChatMessage", function(msg, chatType) ns.SafeCall("linked chat", LinkedChat.OnOwnSend, msg, chatType) end) -- gp:linked-chat
	end
	if type(C_ChatInfo) == "table" and type(C_ChatInfo.SendChatMessage) == "function" then -- gp:linked-chat
		hooksecurefunc(C_ChatInfo, "SendChatMessage", function(msg, chatType) ns.SafeCall("linked chat", LinkedChat.OnOwnSend, msg, chatType) end) -- gp:linked-chat
	end
end

ns.On("LOGIN", function()
	local c = CharDB()
	local cache = c and c.cache
	if type(cache) == "table" and cache.channel and (not cache.guild or cache.guild == MyGuild()) then
		S.cfg = { channel = cache.channel, password = cache.password or "", tag = cache.tag or "GUILD" }
	end
	if ns.Gate.Allowed("system-filters") then
		local add = ChatFrame_AddMessageEventFilter or (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter) -- gp:system-filters
		if type(add) == "function" then add("CHAT_MSG_CHANNEL", LinkedChat.Filter) end -- gp:system-filters
	end
	Roster()
	LinkedChat.Read()
	LinkedChat.Ensure()
	ns.Every(LinkedChat.TICK, "linked chat", function() Roster(); LinkedChat.Read(); LinkedChat.Ensure() end)
end)
for _, event in ipairs({ "CHAT_MSG_CHANNEL", "GUILD_ROSTER_UPDATE", "PLAYER_GUILD_UPDATE", "PLAYER_REGEN_ENABLED" }) do
	pcall(ns.RegisterEvent, event, function(...)
		if event == "CHAT_MSG_CHANNEL" then return ns.SafeCall("linked chat", LinkedChat.OnChannel, ...) end
		ns.SafeCall("linked chat", function() Roster(); LinkedChat.Read() end)
	end)
end
