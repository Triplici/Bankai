-- BankaiGuild/Shogun.lua as 0.9.8 ships it, for tests/run.lua: copied unchanged from
-- `git show v0.9.8:BankaiGuild/Shogun.lua`. 0.9.9's differs only in how the crown is drawn on the map
-- (the gamepad UI): its Hands of the Shogun (Authorized, OnHands, HandleCommand) are these. A client
-- of those versions takes the list of Hands from the Shogun's pinned character alone, reads the
-- names after the guild and never reads the number before it, and leaves out a kind of T1 it
-- does not know (1.0.0: a Steward's own list, T1~N). Loaded on a namespace of its own:
--   loadfile("tests/fixtures/shogun-0.9.8.lua")("BankaiGuild", kns)   -- kns.Shogun
local ADDON, ns = ...
local L = ns.L

-- The Throne: a tab for the Shogun alone (the guild master of the guild named exactly
-- "Bankai Guild" of his faction, and that very character where the addon knows him by name,
-- ns.SHOGUN_CHARACTER), and for the Hands he names. What he sends goes out on the Bankai Guild
-- channel as T1 messages, and every client checks that the sender really is him (his name,
-- which the server sets: never a census vote, which anyone on the channel can cast), or one
-- of his Hands for the tools he lends them (HAND_MAY). Answers go back to whoever asked,
-- alone (T2, T3 as whispered addon messages).
--   T1~S~<id>~<guild>                      Summon the Elders (roll call)
--   T1~I~<id>~<guild>                      Royal Inspection: every addon patrols 2 minutes
--   T1~A~<id>~<guild>~<minutes>~<zone>~<title>   The Shogun's Agenda (resent every 5 min)
--   T1~X~<id>~<guild>                      Agenda cancelled
--   T1~H~<id>~<guild>~<Name-Realm,...>     the Hands of the Shogun (his alone; resent every 5 min)
--   T2~<id>~<P|B>~<guild>                  an Elder's answer to the roll call
--   T3~<id>~<guild>~<ok>~<none>~<other>~<name:guild,...>   an inspection report
-- Other modules add their own kinds (Shogun.Register): Poll (V, E), writs (W), the court
-- (C, Z), the gates (G), pardons (F).

local Shogun = {}
ns.Shogun = Shogun

Shogun.SUMMON_OPEN = 60        -- the popup stays this long
Shogun.SUMMON_GAP = 60         -- one roll call a minute at most (sent or accepted)
Shogun.INSPECT_TIME = 120      -- each addon patrols this long
Shogun.INSPECT_GAP = 1800      -- one Royal Inspection every 30 minutes at most (0.9.2), whoever calls it
-- The realm's share of the load (0.9.2). An inspect is one request to the server for a player
-- in reach. Budget: INSPECT_BUDGET requests a second across the whole realm. A client on the
-- inspection sends one every INSPECT_PACE seconds at most, so INSPECT_BUDGET * INSPECT_PACE =
-- 100 clients can take part at once; with N addons online (the census counts them) each one
-- takes part with probability 100 / N (all of them while there are 100 or fewer). 3,000 online:
-- 1 in 30, about 20 requests a second for 2 minutes, then nothing for at least 30 minutes.
Shogun.INSPECT_BUDGET = 20
Shogun.INSPECT_PACE = 5
Shogun.AGENDA_RESEND = 300     -- the Shogun's client repeats the agenda for late logins
Shogun.MAX_NAMES = 6           -- violators per inspection report (message size)
Shogun.AGENDA_GAP = 60         -- one new agenda a minute at most (each one is a raid warning)
Shogun.MAX_ANSWERS = 150       -- roll-call answers kept
Shogun.MAX_REPORTS = 150       -- inspection reports kept
Shogun.MAX_CHECKS = 60         -- checks one patrol can report in 2 minutes
Shogun.MAX_SHOWN = 30          -- violators listed on the page

Shogun.MAX_HANDS = 40          -- Hands of the Shogun (the list goes out in pieces when long)
Shogun.HANDS_EVERY = 300       -- the Shogun's client repeats the list for late logins
Shogun.HANDS_FRESH = 20 * 60   -- a list the Shogun stopped repeating (he left) ends

Shogun.mode = nil              -- what the tab shows: home, hands or letter (nil: the letter until
                             -- the Shogun has read it, then home)
local summon, inspect        -- the Shogun's own roll call / inspection in progress
local agenda                 -- the agenda everyone sees: { id, title, at, zone, by }
local lastSummonSeen, lastInspectSeen, inspecting = -math.huge, -math.huge, nil
local lastSummonSent, lastInspectSent = -math.huge, -math.huge
local lastAgendaSent, lastAgendaWarn = -math.huge, -math.huge

-- Text other players send that ends up on the Shogun's screen (on stream): only what looks
-- like a character name ("Pyralis Ashandar") or an Bankai Guild guild name, nothing else.
local function CleanName(s)
	s = tostring(s or ""):gsub("%-.*$", "")
	if #s > 30 or not s:match("^[%a\128-\255]+ ?[%a\128-\255]*$") then return nil end
	return s
end
local function CleanGuild(s)
	s = tostring(s or ""):gsub("[%c|]", "")
	if #s > 24 or not ns.IsFederation(s) or not s:match("^[%w\128-\255 ]+$") then return nil end
	return s
end

-- Someone we can place: our own guild (the server's roster) or an Elder or Council member the census
-- confirms (Data.KnownRank). Only they may put names on the Shogun's page.
local function Verified(sender, guild)
	if ns.Roster.RankOf(sender) then return true end
	local rank = guild and ns.Data.KnownRank(sender, guild)
	return rank ~= nil and rank <= ns.COUNCIL_MEMBER_RANK
end

---------------------------------------------------------------------------
-- Who
---------------------------------------------------------------------------

-- Where the Shogun is pinned by name, another guild master of his guild is not him: nobody
-- would obey the powers the Throne gave that character.
function Shogun.IsShogun()
	if not ns.IsMember() then return false end
	local guild, _, rank = GetGuildInfo("player")
	if not (ns.IsShogunGuild(guild) and rank == 0) then return false end
	return ns.ShogunCharacter() == nil or ns.IsShogunCharacter(ns.me)
end

-- The author's test build (Dev.lua, never published) shows the tab without the powers:
-- nothing it does reaches anyone. The author turns this "Shobek's view" on and off from the
-- Workshop (ns.db.devShogunView).
function Shogun.Preview()
	if Shogun.IsShogun() then return false end
	local view = ns.db and ns.db.devShogunView
	if view ~= nil and ns.Workshop and ns.Workshop.Visible and ns.Workshop.Visible() then return view == true end
	local dev = ns.devThrone
	if type(dev) == "table" then dev = dev[UnitName and UnitName("player") or ""] == true or dev[ns.ShortName(ns.me or "")] == true end
	return dev == true and not Shogun.IsShogun()
end
function Shogun.Visible() return Shogun.IsShogun() or Shogun.IsHand() or Shogun.Preview() end

-- Where the Shogun is pinned by name (ns.SHOGUN_CHARACTER): that character alone, speaking for
-- the Shogun's guild. No census vote can crown anyone else, nor silence him. Where he is not
-- (the Horde, until his name is known) nobody's commands are obeyed; soft: what only shows
-- (his position, his name on the lines) still comes from the census there (Data.KnownRank).
local function ShogunSender(sender, guild, soft)
	if not ns.IsShogunGuild(guild) then return false end
	if ns.ShogunCharacter() then
		if not ns.IsShogunCharacter(sender) then return false end
		ns.LearnShogunRealm(sender) -- (the Horde's, while unknown: from the server's name)
		return true
	end
	return soft == true and ns.Data.KnownRank(sender, guild, true) == 0
end

-- The page refreshes at most once a second, whatever arrives.
local changePending = false
local function Changed()
	if changePending then return end
	changePending = true
	ns.After(1, "throne refresh", function()
		changePending = false
		ns.Fire("THRONE_CHANGED")
	end)
end

local function Warn(text, loud)
	ns.Print("|cffffd200" .. text .. "|r")
	if RaidNotice_AddMessage and RaidWarningFrame then
		RaidNotice_AddMessage(RaidWarningFrame, text, ChatTypeInfo and ChatTypeInfo["RAID_WARNING"] or { r = 1, g = 0.82, b = 0 })
	end
	ns.PlayAlert(loud and "loud" or "soft")
end

local function NewId() return math.random(1, 99999) end

---------------------------------------------------------------------------
-- The Hands of the Shogun: the players he names use the Throne's tools in his name (HAND_MAY:
-- the roll call, the inspection, the agenda, Poll, the gates), never what is his alone
-- (the Hands, writs, the court, pardons, his position). Each client keeps the list of the
-- Shogun it trusts, as he last sent it; a list he stopped repeating ends (HANDS_FRESH).
---------------------------------------------------------------------------

Shogun.HAND_MAY = { S = true, I = true, A = true, X = true, V = true, E = true, G = true }
local hands = {}         -- [Name-Realm] = true, as the Shogun last sent it
local handsAt = -math.huge
local handsShogun          -- who sent that list (the Shogun's name on a Hand's Throne Room)
local myHands = {}       -- the Shogun's own list, in order: { "Name-Realm", ... } (saved: rdb.shogunHands)
local lastHandsSent = -math.huge
local handsSendPending = false

-- On the Shogun's own client his list is the one he keeps (his broadcast never comes back to
-- him); everyone else trusts the list he last sent, while he keeps sending it.
local function Hand(name)
	local full = ns.FullName(name)
	if Shogun.IsShogun() then
		for _, n in ipairs(myHands) do if n == full then return true end end
		return false
	end
	return ns.Now() - handsAt <= Shogun.HANDS_FRESH and hands[full] == true
end

function Shogun.IsHand() return not Shogun.IsShogun() and ns.IsMember() and Hand(ns.me) end
function Shogun.Hands() return myHands end

-- The Shogun may send it, or one of his Hands if it is theirs to use too (soft: his position).
function Shogun.Authorized(kind, sender, guild)
	if ShogunSender(sender, guild, kind == "P" or kind == "Q") then return true end
	return Shogun.HAND_MAY[kind] == true and Hand(sender)
end

-- The Shogun, or a Hand: the tools of the Throne.
function Shogun.CanCommand() return Shogun.IsShogun() or Shogun.IsHand() end

-- The Shogun himself sent it (not a Hand): for how it is shown.
function Shogun.FromShogun(sender, guild) return ShogunSender(sender, guild, true) end

-- The Shogun's list, kept across sessions (a /reload must not drop his Hands).
local function SaveHands()
	if not ns.rdb then return end
	local copy = {}
	for i, n in ipairs(myHands) do copy[i] = n end
	ns.rdb.shogunHands = copy
end

-- Several changes in a row go out as one list, a few seconds after the last one.
local function SendHandsSoon()
	if handsSendPending then return end
	handsSendPending = true
	ns.After(3, "shogun hands", function()
		handsSendPending = false
		Shogun.SendHands(true)
	end)
end

-- The Shogun's list goes out whole: short in one message, long in pieces (Comm.SendChunked).
function Shogun.SendHands(force)
	if not Shogun.IsShogun() then return end
	local now = ns.Now()
	if not force and now - lastHandsSent < Shogun.HANDS_EVERY then return end
	if #myHands == 0 and lastHandsSent == -math.huge then return end -- nobody named yet
	lastHandsSent = now
	local msg = ("T1~H~%d~%s~%s"):format(NewId(), GetGuildInfo("player") or "", table.concat(myHands, ","))
	if #msg <= 250 then ns.Comm.Send("CHANNEL", msg, "hands") else ns.Comm.SendChunked(msg) end
end

-- A name typed or targeted, as the server writes it; nil if it can't be a character.
local function HandName(input)
	local name = tostring(input or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" then
		name = UnitIsPlayer and UnitIsPlayer("target") and ns.UnitFullName("target") or ""
	end
	name = ns.Normal(name)
	local short = CleanName(name)
	if not short then return nil end
	return ns.FullName(short, ns.RealmOf(name))
end

function Shogun.AddHand(input)
	if not Shogun.IsShogun() and not Shogun.Preview() then return ns.Print(L.THRONE_ONLY_SHOGUN) end
	local name = HandName(input)
	if not name then return ns.Print(L.HANDS_WHO) end
	if name == ns.me then return end
	for _, n in ipairs(myHands) do if n == name then return end end
	if #myHands >= Shogun.MAX_HANDS then return ns.Print(L.HANDS_FULL:format(Shogun.MAX_HANDS)) end
	myHands[#myHands + 1] = name
	SaveHands()
	ns.Print(L.HANDS_ADDED:format(ns.DisplayName(name)))
	if Shogun.IsShogun() then SendHandsSoon() end
	Shogun.mode = "hands"
	Changed()
end

function Shogun.RemoveHand(name)
	for i, n in ipairs(myHands) do
		if n == name then
			table.remove(myHands, i)
			SaveHands()
			ns.Print(L.HANDS_REMOVED:format(ns.DisplayName(name)))
			if Shogun.IsShogun() then SendHandsSoon() end
			return Changed()
		end
	end
end

local function OnHands(shogun, rest)
	local list, n = {}, 0
	for name in tostring(rest or ""):gmatch("[^,]+") do
		local short = CleanName(name)
		if short and n < Shogun.MAX_HANDS then
			list[ns.FullName(short, ns.RealmOf(name))] = true
			n = n + 1
		end
	end
	local was = Shogun.IsHand()
	hands, handsAt, handsShogun = list, ns.Now(), ns.FullName(shogun)
	local now = Shogun.IsHand()
	if now and not was then
		ns.Print(L.HANDS_YOU:format(ns.ShogunName(shogun)))
		ns.PlayAlert("soft")
		ns.Fire("DATA_CHANGED") -- the Throne's tab appears
	elseif was and not now then
		ns.Fire("DATA_CHANGED")
	end
	Changed()
end

StaticPopupDialogs["BANKAIGUILD_SHOGUN_HAND"] = {
	text = L.HANDS_PROMPT,
	button1 = OKAY or "OK",
	button2 = CANCEL or "Cancel",
	hasEditBox = true,
	editBoxWidth = 240,
	maxLetters = 40,
	OnShow = function(self)
		local eb = self.editBox or self.EditBox
		if eb then
			local target = UnitIsPlayer and UnitIsPlayer("target") and ns.UnitFullName("target")
			eb:SetText(target and ns.DisplayName(target) or "")
			eb:SetFocus()
		end
	end,
	OnAccept = function(self)
		local eb = self.editBox or self.EditBox
		ns.SafeCall("add hand", Shogun.AddHand, eb and eb:GetText())
	end,
	EditBoxOnEnterPressed = function(self)
		ns.SafeCall("add hand", Shogun.AddHand, self:GetText())
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["BANKAIGUILD_SHOGUN_UNHAND"] = {
	text = L.HANDS_REMOVE_CONFIRM,
	button1 = YES or "Yes",
	button2 = NO or "No",
	OnAccept = function(self, data) ns.SafeCall("remove hand", Shogun.RemoveHand, data or (self and self.data)) end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-- Other modules' kinds of T1 (Poll, writs, the court, the gates, pardons):
-- fn(sender, id, rest, guild), called once Shogun.Authorized agreed.
local kinds = {}
function Shogun.Register(kind, fn) kinds[kind] = fn end
Shogun.Changed = function() Changed() end
Shogun.Warn = function(text, loud) Warn(text, loud) end
Shogun.NewId = function() return NewId() end
Shogun.CleanName = function(s) return CleanName(s) end
Shogun.CleanGuild = function(s) return CleanGuild(s) end
Shogun.Verified = function(sender, guild) return Verified(sender, guild) end

-- Our tabard, checked the way a patrol checks others (level 15+ only: the Bankai Guild rule).
local function OwnTabard()
	local level = UnitLevel and UnitLevel("player") or 0
	if level > 0 and level < (ns.Inspect.MIN_LEVEL or 15) then return nil end
	local item = GetInventoryItemID and GetInventoryItemID("player", INVSLOT_TABARD or 19)
	return ns.Inspect.Classify(item, true)
end

---------------------------------------------------------------------------
-- Summon the Elders
---------------------------------------------------------------------------

function Shogun.Summon()
	local now = ns.Now()
	if Shogun.Preview() then
		summon = { id = 0, t = now, answers = {}, preview = true }
		ns.Print(L.THRONE_PREVIEW_NOTE)
		return Changed()
	end
	if not Shogun.CanCommand() then return end
	if now - lastSummonSent < Shogun.SUMMON_GAP then
		ns.Print(L.THRONE_WAIT:format(math.ceil(Shogun.SUMMON_GAP - (now - lastSummonSent))))
		return Changed()
	end
	lastSummonSent = now
	summon = { id = NewId(), t = now, answers = {} }
	ns.Comm.Send("CHANNEL", ("T1~S~%d~%s"):format(summon.id, GetGuildInfo("player")))
	ns.Log("throne: summon %d", summon.id)
	Changed()
end

local function OnSummon(shogun, id, guild)
	local now = ns.Now()
	if now - lastSummonSeen < Shogun.SUMMON_GAP then return end
	if not ns.IsMember() or ns.Roster.MyRank() > ns.COUNCIL_MEMBER_RANK then return end
	lastSummonSeen = now
	ns.PlayAlert("soft")
	-- The Shogun by the army's name for him; a Hand by theirs.
	local who = Shogun.FromShogun(shogun, guild) and L.THRONE_SUMMONED:format(ns.ShogunName(shogun)) or L.THRONE_SUMMONED_HAND:format(ns.DisplayName(shogun))
	ns.ShowDialog("BANKAIGUILD_SHOGUN_SUMMON", who, nil, { shogun = shogun, id = id })
end

local function Answer(data, word)
	if not data or not data.shogun then return end
	ns.Comm.Whisper(data.shogun, ("T2~%d~%s~%s"):format(data.id, word, GetGuildInfo("player") or ""))
end

StaticPopupDialogs["BANKAIGUILD_SHOGUN_SUMMON"] = {
	text = "%s",
	button1 = L.THRONE_PRESENT,
	button2 = L.THRONE_BUSY,
	OnAccept = function(self, data) ns.SafeCall("throne answer", Answer, data or self.data, "P") end,
	OnCancel = function(self, data, reason)
		if reason == "clicked" then ns.SafeCall("throne answer", Answer, data or self.data, "B") end
	end,
	timeout = Shogun.SUMMON_OPEN,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-- The Elders and Council the census knows online, answered or not: { name, guild, rank }.
local function EldersOnline()
	local out = {}
	for _, e in ipairs(ns.Data.Summary().guilds) do
		local g = e.g
		if e.fresh then
			local home = g.realm or ns.realm
			if g.leader and g.leaderOnline then out[#out + 1] = { name = ns.FullName(g.leader, home), guild = e.name, rank = 0 } end
			for _, o in ipairs(g.officers or {}) do
				if o.online then out[#out + 1] = { name = ns.FullName(o.name, home), guild = e.name, rank = 1 } end
			end
		end
	end
	return out
end

function Shogun.HandleAnswer(dist, sender, text)
	if dist ~= "WHISPER" or not summon or summon.preview then return end
	local id, word, guild = text:match("^T2~(%d+)~([PB])~(.*)$")
	if tonumber(id) ~= summon.id or ns.Now() - summon.t > 300 then return end
	sender = ns.FullName(sender)
	if summon.answers[sender] then return end -- one answer each
	guild = CleanGuild(guild)
	-- Only confirmed Elders and Council are listed by name; anyone else is just counted.
	if not guild or not Verified(sender, guild) then
		summon.others = summon.others or {}
		if not summon.others[sender] then
			local n = 0
			for _ in pairs(summon.others) do n = n + 1 end
			if n < Shogun.MAX_ANSWERS then summon.others[sender] = word end
		end
		return Changed()
	end
	local n = 0
	for _ in pairs(summon.answers) do n = n + 1 end
	if n >= Shogun.MAX_ANSWERS then return end
	summon.answers[sender] = { word = word, guild = guild, verified = true, t = ns.Now() }
	Changed()
end
ns.Comm.Handle("T2", function(...) Shogun.HandleAnswer(...) end)

---------------------------------------------------------------------------
-- Royal Inspection
---------------------------------------------------------------------------

function Shogun.Inspect()
	local now = ns.Now()
	if Shogun.Preview() then
		ns.Print(L.THRONE_PREVIEW_NOTE)
		inspect = { id = 0, t = now, reports = {}, preview = true }
		Shogun.RunInspection(nil, 0) -- our own patrol only, reported to ourselves
		return Changed()
	end
	if not Shogun.CanCommand() then return end
	if now - lastInspectSent < Shogun.INSPECT_GAP then
		ns.Print(L.THRONE_WAIT:format(math.ceil(Shogun.INSPECT_GAP - (now - lastInspectSent))))
		return Changed()
	end
	lastInspectSent = now
	inspect = { id = NewId(), t = now, reports = {} }
	ns.Comm.Send("CHANNEL", ("T1~I~%d~%s"):format(inspect.id, GetGuildInfo("player")))
	ns.Log("throne: inspection %d", inspect.id)
	Shogun.RunInspection(ns.me, inspect.id) -- the Shogun patrols too
	Changed()
end

-- Every addon (the Shogun's too): a raid warning, a patrol of INSPECT_TIME, then a report to
-- the Shogun of what it saw (and our own tabard).
function Shogun.RunInspection(shogun, id)
	if inspecting or not ns.IsMember() then return end
	local start = ns.Now()
	inspecting = { shogun = shogun, id = id, start = start, wasOn = ns.Inspect.IsPatrolling() }
	Warn(L.THRONE_INSPECT_WARN, true)
	if not inspecting.wasOn then ns.Inspect.SetPatrol(true) end
	ns.Inspect.SetPace(Shogun.INSPECT_PACE) -- the realm's budget (INSPECT_BUDGET)
	ns.After(Shogun.INSPECT_TIME, "royal inspection", function()
		local run = inspecting
		inspecting = nil
		ns.Inspect.SetPace(nil)
		if not run then return end
		if not run.wasOn and ns.Inspect.IsPatrolling() then ns.Inspect.SetPatrol(false) end
		local ok, none, other, names = 0, 0, 0, {}
		-- A patrol does not re-inspect anyone checked in the last 10 minutes: those count too.
		for name, p in pairs(ns.Inspect.Players()) do
			if (p.t or 0) >= run.start - 600 then
				if p.status == "GUILD" then ok = ok + 1
				elseif p.status == "NONE" or p.status == "OTHER" then
					if p.status == "NONE" then none = none + 1 else other = other + 1 end
					if #names < Shogun.MAX_NAMES then names[#names + 1] = (ns.DisplayName(name) or "?") .. ":" .. (p.guild or "?") .. ":" .. (p.status == "NONE" and "N" or "O") end
				end
			end
		end
		local own = OwnTabard()
		if own == "GUILD" then ok = ok + 1 elseif own == "NONE" then none = none + 1 elseif own == "OTHER" then other = other + 1 end
		local guild = GetGuildInfo("player") or ""
		local msg = ("T3~%d~%s~%d~%d~%d~%s"):format(run.id or 0, guild, ok, none, other, table.concat(names, ","))
		if run.shogun == ns.me or not run.shogun then
			Shogun.ReceiveReport(ns.me, msg) -- ours (the Shogun's, or the preview's)
		else
			ns.Comm.Whisper(run.shogun, msg:sub(1, 250))
		end
	end)
end

-- The addons online the census knows of (fresh reports), at least 1.
function Shogun.AddonsOnline()
	local n = 0
	for _, e in ipairs(ns.Data.Summary().guilds) do
		if e.fresh then n = n + (tonumber(e.g.users) or 0) end
	end
	return math.max(n, 1)
end

-- This client's chance to take part in an inspection (see INSPECT_BUDGET).
function Shogun.InspectShare()
	return math.min(1, Shogun.INSPECT_BUDGET * Shogun.INSPECT_PACE / Shogun.AddonsOnline())
end
Shogun.random = math.random -- tests

local function OnInspect(shogun, id)
	local now = ns.Now()
	if now - lastInspectSeen < Shogun.INSPECT_GAP then return end
	lastInspectSeen = now
	-- Everyone hears the Shogun's call; only a sample of the army patrols (and reports), and never
	-- a player who said no (/bk inspection off, 0.9.3).
	if ns.db and ns.db.royalInspection == false then
		ns.Log("inspection %d: not taking part (/bk inspection off)", id or 0)
		return Warn(L.THRONE_INSPECT_WARN, true)
	end
	if Shogun.random() > Shogun.InspectShare() then
		ns.Log("inspection %d: not in this sample (%.2f)", id or 0, Shogun.InspectShare())
		return Warn(L.THRONE_INSPECT_WARN, true)
	end
	Shogun.RunInspection(shogun, id)
end

function Shogun.ReceiveReport(sender, text)
	if not inspect then return end
	local id, guild, ok, none, other, names = text:match("^T3~(%d+)~([^~]*)~(%d+)~(%d+)~(%d+)~(.*)$")
	if not id or tonumber(id) ~= inspect.id or ns.Now() - inspect.t > 900 then return end
	sender = ns.FullName(sender)
	if inspect.reports[sender] then return end -- one report each
	local n = 0
	for _ in pairs(inspect.reports) do n = n + 1 end
	if n >= Shogun.MAX_REPORTS then return end
	guild = CleanGuild(guild)
	if not guild then return end
	-- Only from someone we can place in that guild (our own, a confirmed Elder or Council member):
	-- nobody else writes names or numbers on the Shogun's page.
	if sender ~= ns.me and not Verified(sender, guild) then return end
	local list = {}
	for entry in names:gmatch("[^,]+") do
		local nm, g, st = entry:match("^([^:]+):([^:]*):([NO])$")
		nm, g = CleanName(nm), CleanGuild(g)
		if nm and g and #list < Shogun.MAX_NAMES then list[#list + 1] = { name = nm, guild = g, status = st == "N" and "NONE" or "OTHER" } end
	end
	local cap = Shogun.MAX_CHECKS
	inspect.reports[sender] = { guild = guild, ok = math.min(tonumber(ok) or 0, cap),
		none = math.min(tonumber(none) or 0, cap), other = math.min(tonumber(other) or 0, cap), names = list }
	Changed()
end

function Shogun.HandleReport(dist, sender, text)
	if dist ~= "WHISPER" or not Shogun.CanCommand() then return end
	Shogun.ReceiveReport(sender, text)
end
ns.Comm.Handle("T3", function(...) Shogun.HandleReport(...) end)

-- The violators the inspection found go on the Shogun's own list, then the usual Wall of Shame.
-- The untabarded (Inspect.lua): the Shogun's list, the army's only while he lets it see it.
--   T1~U~<id>~<guild>~1~<name>:<guild>,...   the list, repeated while it is on
--   T1~U~<id>~<guild>~0                      off: it leaves every screen
-- Only the Shogun (not a Hand: "U" is not in HAND_MAY). Older versions ignore the kind.
Shogun.UNTABARDED_EVERY = 300
local lastUntabardedSent = -math.huge

function Shogun.SharingUntabarded() return ns.db and ns.db.shogunUntabarded == true end

-- What the inspection's patrols reported joins his own list.
local function TakeReports()
	for _, r in pairs(inspect and inspect.reports or {}) do
		for _, v in ipairs(r.names) do ns.Inspect.AddReported(v.name, v.guild, v.status) end
	end
end

function Shogun.SendUntabarded(force)
	if not Shogun.IsShogun() then return end
	local now = ns.Now()
	local on = Shogun.SharingUntabarded()
	if not force and (not on or now - lastUntabardedSent < Shogun.UNTABARDED_EVERY) then return end
	lastUntabardedSent = now
	local guild = GetGuildInfo("player") or ""
	local msg
	if on then
		TakeReports()
		local body = ns.Codec.EncodeShame(guild, 0, ns.Inspect.ShameList()):match("^S1~[^~]*~%d+~(.*)$") or ""
		msg = ("T1~U~%d~%s~1~%s"):format(NewId(), guild, body)
	else
		msg = ("T1~U~%d~%s~0"):format(NewId(), guild)
	end
	if #msg <= 250 then ns.Comm.Send("CHANNEL", msg, "untabarded") else ns.Comm.SendChunked(msg) end
end

function Shogun.ToggleUntabarded()
	if Shogun.Preview() then return ns.Print(L.THRONE_PREVIEW_NOTE) end
	if not Shogun.IsShogun() then return ns.Print(L.THRONE_ONLY_SHOGUN) end
	ns.db.shogunUntabarded = not Shogun.SharingUntabarded()
	ns.Print(Shogun.SharingUntabarded() and L.UNTABARDED_ON or L.UNTABARDED_OFF)
	Shogun.SendUntabarded(true)
	Changed()
end

local function OnUntabarded(sender, rest)
	if Shogun.IsShogun() then return end
	local on, body = tostring(rest or ""):match("^(%d)~?(.*)$")
	if on == "1" then
		local s = ns.Codec.DecodeShame("S1~Bankai Guild~0~" .. body)
		if s then ns.Inspect.ShowShame({ by = ns.ShogunName(sender), list = s.list, t = ns.Now() }) end
	elseif on == "0" then
		ns.Inspect.ShowShame(nil)
	end
end

---------------------------------------------------------------------------
-- The Shogun's Agenda
---------------------------------------------------------------------------

local function ZoneName()
	return (GetRealZoneText and GetRealZoneText()) or (GetZoneText and GetZoneText()) or ""
end

local function Clean(s, n) return ns.Cut((tostring(s or ""):gsub("[~|\n]", " ")), n) end

-- "30 Raid on Crossroads": minutes first, then the title.
function Shogun.ParseAgenda(input)
	local minutes, title = tostring(input or ""):match("^%s*(%d+)%s+(.-)%s*$")
	minutes = tonumber(minutes)
	if not minutes or minutes < 1 or minutes > 720 or title == "" then return nil end
	return minutes, Clean(title, 60)
end

function Shogun.SetAgenda(input)
	local minutes, title = Shogun.ParseAgenda(input)
	if not minutes then
		ns.Print(L.THRONE_AGENDA_USAGE)
		return false
	end
	local now = ns.Now()
	if not Shogun.Preview() and now - lastAgendaSent < Shogun.AGENDA_GAP then
		ns.Print(L.THRONE_WAIT:format(math.ceil(Shogun.AGENDA_GAP - (now - lastAgendaSent))))
		return false
	end
	lastAgendaSent = now
	local mine = { id = NewId(), title = title, at = now + minutes * 60, zone = Clean(ZoneName(), 40), by = ns.me, mine = true, fired = {} }
	if Shogun.Preview() then
		agenda = mine
		ns.Print(L.THRONE_PREVIEW_NOTE)
		return Changed() or true
	end
	if not Shogun.CanCommand() then return false end
	agenda = mine
	Shogun.SendAgenda()
	Warn(L.THRONE_AGENDA_SET:format(title, minutes, mine.zone))
	Changed()
	return true
end

function Shogun.SendAgenda()
	if not agenda or not agenda.mine or Shogun.Preview() then return end
	-- Seconds left, so a resend never moves the time (minutes rounded up did).
	local left = math.floor(agenda.at - ns.Now())
	if left < 30 then return end
	ns.Comm.Send("CHANNEL", ("T1~A~%d~%s~%d~%s~%s"):format(agenda.id, GetGuildInfo("player") or "", left, agenda.zone, agenda.title), "agenda")
end

function Shogun.CancelAgenda()
	if not agenda then return end
	-- The Shogun or a Hand cancels it for everyone, whoever set it (its setter's client stops
	-- repeating it when the cancel reaches it).
	if (agenda.mine or Shogun.CanCommand()) and not Shogun.Preview() then
		ns.Comm.Send("CHANNEL", ("T1~X~%d~%s"):format(agenda.id, GetGuildInfo("player") or ""), "agenda")
	end
	agenda = nil
	Changed()
end

function Shogun.Agenda()
	if agenda and agenda.at < ns.Now() - 600 then agenda = nil end -- over for 10 minutes
	return agenda
end

local function OnAgenda(shogun, id, rest, guild)
	local seconds, zone, title = rest:match("^(%d+)~([^~]*)~(.*)$")
	seconds = tonumber(seconds)
	if not seconds or seconds < 30 or seconds > 720 * 60 or title == "" then return end
	local now = ns.Now()
	if agenda and agenda.id == id then
		-- A resend: keep our time unless it is really off (late login, clock drift).
		if math.abs((now + seconds) - agenda.at) > 60 then agenda.at = now + seconds end
		return Changed()
	end
	agenda = { id = id, title = Clean(title, 60), at = now + seconds, zone = Clean(zone, 40), by = shogun, fired = {} }
	-- A new agenda is a raid warning and a popup (the appointment: what, when, where), but
	-- not more than once a minute whatever arrives.
	if now - lastAgendaWarn >= Shogun.AGENDA_GAP then
		lastAgendaWarn = now
		local minutes = math.ceil(seconds / 60)
		Warn(L.THRONE_AGENDA_SET:format(agenda.title, minutes, agenda.zone))
		-- The Shogun by the army's name for him; a Hand by theirs (as OnSummon).
		local where = agenda.zone ~= "" and agenda.zone or "?"
		local text = Shogun.FromShogun(shogun, guild) and L.THRONE_AGENDA_POPUP:format(ns.ShogunName(shogun), agenda.title, minutes, where)
			or L.THRONE_AGENDA_POPUP_HAND:format(ns.DisplayName(shogun), agenda.title, minutes, where)
		ns.ShowDialog("BANKAIGUILD_AGENDA_CALL", text)
	end
	Changed()
end

StaticPopupDialogs["BANKAIGUILD_AGENDA_CALL"] = {
	text = "%s",
	button1 = OKAY or "OK",
	timeout = 120,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

---------------------------------------------------------------------------
-- The Shogun on the map: when he turns it on (Throne tab), his client sends where he is and
-- every addon shows a crown on the world map and the minimap. Off by default, and a button
-- away: his position is on stream.
--   T1~P~<id>~<guild>~<mapID>~<x 0-1000>~<y 0-1000>   where he is (every few seconds while moving)
--   T1~Q~<id>~<guild>                                  hidden again
---------------------------------------------------------------------------

Shogun.LOCATION_EVERY = 5      -- seconds between sends while moving
Shogun.LOCATION_STILL = 20     -- standing still, repeated this often (for late logins)
Shogun.LOCATION_EXPIRE = 45    -- a crown with no news this long is removed

local shogunAt                 -- where the Shogun is, for everyone: { name, mapID, x, y, t }
local locationId = NewId()
local lastLocation = { t = -math.huge }
local Pins = ns.Pins()
local SHOW_FLAG = HBD_PINS_WORLDMAP_SHOW_CONTINENT or 2
local crowns                 -- { world, mini } pin frames, made on first use
local crownAt                -- where they are drawn now (drawn again only when he moved)

function Shogun.SharingLocation() return ns.db.throneLocation == true end

local function SendLocation(force)
	if not Shogun.SharingLocation() or not Shogun.IsShogun() then return end
	if IsInInstance and IsInInstance() then return end
	local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
	local pos = mapID and C_Map.GetPlayerMapPosition and C_Map.GetPlayerMapPosition(mapID, "player")
	if not pos then return end
	local x, y = pos:GetXY()
	if not x or (x == 0 and y == 0) then return end
	local now = ns.Now()
	local moved = lastLocation.mapID ~= mapID or math.abs((lastLocation.x or 0) - x) > 0.003 or math.abs((lastLocation.y or 0) - y) > 0.003
	if not force and (now - lastLocation.t < Shogun.LOCATION_EVERY or (not moved and now - lastLocation.t < Shogun.LOCATION_STILL)) then return end
	lastLocation = { mapID = mapID, x = x, y = y, t = now }
	ns.Comm.Send("CHANNEL", ("T1~P~%d~%s~%d~%d~%d"):format(locationId, GetGuildInfo("player") or "", mapID,
		math.floor(x * 1000 + 0.5), math.floor(y * 1000 + 0.5)), "shogunlocation")
end

function Shogun.ToggleLocation()
	if Shogun.Preview() then return ns.Print(L.THRONE_PREVIEW_NOTE) end
	if not Shogun.IsShogun() then return end
	ns.db.throneLocation = not Shogun.SharingLocation()
	if Shogun.SharingLocation() then
		ns.Print(L.THRONE_LOCATION_SHOWN)
		-- His crown is his yes for his layer too (Layers.lua): the army asks to join him there.
		ns.Print(L.THRONE_LOCATION_LAYER)
		SendLocation(true)
	else
		ns.Print(L.THRONE_LOCATION_HIDDEN)
		lastLocation = { t = -math.huge }
		ns.Comm.Send("CHANNEL", ("T1~Q~%d~%s"):format(locationId, GetGuildInfo("player") or ""), "shogunlocation")
		-- His layer goes with it, at once, and his hello stops naming his zone (Layers.Sharing).
		ns.Layers.Withdraw()
		ns.Comm.Hello(true)
	end
	Changed()
end

local function Crown(size)
	local f = CreateFrame("Frame", nil, UIParent)
	f:SetSize(size, size)
	f.icon = f:CreateTexture(nil, "OVERLAY")
	f.icon:SetTexture(ns.CROWN_ICON)
	f.icon:SetAllPoints()
	f:EnableMouse(true)
	f:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L.THRONE_LOCATION_PIN:format(shogunAt and shogunAt.name or "?"), 1, 0.82, 0)
		GameTooltip:Show()
	end)
	f:SetScript("OnLeave", function() GameTooltip:Hide() end)
	return f
end

-- Draws (or removes) the crown on the world map and the minimap.
function Shogun.RefreshCrown()
	if not Pins then return end
	if shogunAt and ns.Now() - shogunAt.t > Shogun.LOCATION_EXPIRE then shogunAt = nil end
	if not shogunAt then
		if crowns and crownAt then
			Pins:RemoveWorldMapIcon(Shogun, crowns.world)
			Pins:RemoveMinimapIcon(Shogun, crowns.mini)
			crowns.world:Hide()
			crowns.mini:Hide()
		end
		crownAt = nil
		return
	end
	if crownAt and crownAt.mapID == shogunAt.mapID and crownAt.x == shogunAt.x and crownAt.y == shogunAt.y then return end
	crowns = crowns or { world = Crown(20), mini = Crown(16) }
	-- Taken off before it is put back: the map library makes a new map pin on every add.
	if crownAt then
		Pins:RemoveWorldMapIcon(Shogun, crowns.world)
		Pins:RemoveMinimapIcon(Shogun, crowns.mini)
	end
	crownAt = { mapID = shogunAt.mapID, x = shogunAt.x, y = shogunAt.y }
	Pins:AddWorldMapIconMap(Shogun, crowns.world, shogunAt.mapID, shogunAt.x, shogunAt.y, SHOW_FLAG)
	Pins:AddMinimapIconMap(Shogun, crowns.mini, shogunAt.mapID, shogunAt.x, shogunAt.y, true, true)
end

local function OnLocation(shogun, rest)
	local mapID, x, y = rest:match("^(%d+)~(%d+)~(%d+)$")
	mapID, x, y = tonumber(mapID), tonumber(x), tonumber(y)
	if not mapID or x > 1000 or y > 1000 then return end
	shogunAt = { from = ns.FullName(shogun), name = ns.ShogunName(shogun), mapID = mapID, x = x / 1000, y = y / 1000, t = ns.Now() }
	ns.SafeCall("shogun crown", Shogun.RefreshCrown)
	Changed()
end

-- Where the Shogun is, while he shares it: { name, mapID, x, y, t } or nil.
function Shogun.Location()
	if shogunAt and ns.Now() - shogunAt.t > Shogun.LOCATION_EXPIRE then return nil end
	return shogunAt
end

function Shogun.HandleCommand(dist, sender, text)
	if dist ~= "CHANNEL" then return end
	local kind, id, guild, rest = text:match("^T1~(%a)~(%d+)~([^~]*)~?(.*)$")
	if not kind then return end
	if not Shogun.Authorized(kind, sender, guild) then
		-- Positions come every few seconds: not logged.
		if kind ~= "P" then
			ns.Log("throne %s from %s ignored: not the Shogun of %s nor his Hand%s", kind, sender, tostring(guild),
				ns.ShogunCharacter() and "" or " (no Shogun named on this side: nobody commands)")
		end
		return
	end
	id = tonumber(id)
	-- The Shogun's own client takes his Hands' news (the agenda, the gates, a cancel), not
	-- their calls to the army: no roll call popup, patrol or poll window for him.
	if Shogun.IsShogun() and (kind == "S" or kind == "I" or kind == "V") and not ShogunSender(sender, guild) then return end
	if kind == "S" then OnSummon(sender, id, guild)
	elseif kind == "H" then OnHands(sender, rest)
	elseif kinds[kind] then kinds[kind](sender, id, rest, guild)
	elseif kind == "I" then OnInspect(sender, id)
	elseif kind == "U" then OnUntabarded(sender, rest)
	elseif kind == "A" then OnAgenda(sender, id, rest, guild)
	elseif kind == "P" then OnLocation(sender, rest)
	elseif kind == "Q" then
		-- Only whoever put the crown there takes it off.
		if shogunAt and shogunAt.from ~= ns.FullName(sender) then return end
		shogunAt = nil
		ns.SafeCall("shogun crown", Shogun.RefreshCrown)
		Changed()
	elseif kind == "X" and agenda and agenda.id == id then
		agenda = nil
		Changed()
	end
end
ns.Comm.Handle("T1", function(...) Shogun.HandleCommand(...) end)

ns.On("LOGIN", function()
	-- The Shogun's position, while he shares it; everyone's crown expires on its own.
	ns.Every(Shogun.LOCATION_EVERY, "shogun location", function()
		SendLocation()
		Shogun.RefreshCrown()
	end)
	-- His Hands from the last session; he repeats them for late logins (HANDS_EVERY).
	wipe(myHands)
	for _, n in ipairs(ns.rdb and ns.rdb.shogunHands or {}) do
		if type(n) == "string" and #myHands < Shogun.MAX_HANDS then myHands[#myHands + 1] = n end
	end
	ns.Every(60, "shogun hands", function()
		Shogun.SendHands()
		Shogun.SendUntabarded()
	end)
	-- The guild is not always known at login yet: checked when the note is due.
	ns.After(20, "shogun location note", function()
		if Shogun.SharingLocation() and Shogun.IsShogun() then ns.Print(L.THRONE_LOCATION_SHOWN) end
		-- A Shogun no update has named yet (the Horde's): his commands reach nobody (ShogunSender).
		if Shogun.IsShogun() and not ns.ShogunCharacter() then ns.Print(L.THRONE_NOT_NAMED) end
	end)
	ns.Every(60, "agenda", function()
		local a = Shogun.Agenda()
		if not a then return end
		local left = a.at - ns.Now()
		-- Reminders for everyone, and the Shogun's client repeats it for late logins.
		a.fired = a.fired or {}
		for _, mark in ipairs({ 600, 60 }) do
			if left <= mark and left > 0 and not a.fired[mark] then
				a.fired[mark] = true
				Warn(L.THRONE_AGENDA_SOON:format(a.title, math.max(1, math.ceil(left / 60)), a.zone))
			end
		end
		if a.mine and (not a.sentAt or ns.Now() - a.sentAt >= Shogun.AGENDA_RESEND) then
			a.sentAt = ns.Now()
			Shogun.SendAgenda()
		end
		Changed()
	end)
end)

StaticPopupDialogs["BANKAIGUILD_SHOGUN_AGENDA"] = {
	text = L.THRONE_AGENDA_PROMPT,
	button1 = OKAY or "OK",
	button2 = CANCEL or "Cancel",
	hasEditBox = true,
	editBoxWidth = 260,
	maxLetters = 70,
	OnShow = function(self)
		local eb = self.editBox or self.EditBox
		if eb then eb:SetText("30 "); eb:SetFocus() end
	end,
	OnAccept = function(self)
		local eb = self.editBox or self.EditBox
		ns.SafeCall("agenda", Shogun.SetAgenda, eb and eb:GetText())
	end,
	EditBoxOnEnterPressed = function(self)
		ns.SafeCall("agenda", Shogun.SetAgenda, self:GetText())
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

function Shogun.AgendaPrompt()
	ns.ShowDialog("BANKAIGUILD_SHOGUN_AGENDA")
	Changed()
end

---------------------------------------------------------------------------
-- What the tab shows (parchment, dark text: line.font)
---------------------------------------------------------------------------

local INK, TITLE = "QuestFont", "QuestTitleFont"

local function Line(text, font, extra)
	local l = { text = text, font = font or INK }
	for k, v in pairs(extra or {}) do l[k] = v end
	return l
end

-- A paragraph in rows short enough for the page (rows are one line each): split at spaces,
-- about `width` letters a row. The last row takes `extra` (gapAfter...).
Shogun.WRAP = 44
local function Para(lines, text, font, extra)
	local row, rows = "", {}
	for word in tostring(text or ""):gmatch("%S+") do
		if row ~= "" and #row + 1 + #word > Shogun.WRAP then
			rows[#rows + 1] = row
			row = word
		else
			row = row == "" and word or (row .. " " .. word)
		end
	end
	if row ~= "" then rows[#rows + 1] = row end
	for i, r in ipairs(rows) do lines[#lines + 1] = Line(r, font, i == #rows and extra or nil) end
	return lines
end
Shogun.Para = Para

function Shogun.LetterLines()
	local lines = {}
	for part in (L.THRONE_LETTER .. "\n"):gmatch("(.-)\n") do
		lines[#lines + 1] = Line(part, part:find("^%*") and TITLE or INK)
		if part:find("^%*") then lines[#lines].text = part:sub(2) end
	end
	return lines
end

---------------------------------------------------------------------------
-- Where the Shogun's calls show: the roll call in the Realm tab (next to the Elders it calls),
-- the Royal Inspection in the Tabards tab. Plain rows (not the parchment), for the Shogun and
-- his Hands (and the author's Shobek's view).
---------------------------------------------------------------------------

local function Grey(s) return "|cff9d9d9d" .. s .. "|r" end
local function Gold(s) return "|cffffd200" .. s .. "|r" end
local function Green(s) return "|cff40ff40" .. s .. "|r" end
local READY = "|TInterface\\RaidFrame\\ReadyCheck-Ready:13:13|t "
local NOT_READY = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:13:13|t "
local WAITING = "|TInterface\\RaidFrame\\ReadyCheck-Waiting:13:13|t "
Shogun.ROLL_SHOWN = 15 * 60    -- the marks next to the Elders stay this long after a roll call

function Shogun.CanCall() return Shogun.CanCommand() or Shogun.Preview() end

-- Who answered the roll call: present and busy (confirmed Elders and Council), the others
-- the census can't confirm (counted), and the Elders online who stayed silent.
local function RollCall()
	if not summon then return nil end
	local present, busy, silent, others = {}, {}, {}, 0
	for name, a in pairs(summon.answers) do
		local row = ("%s <%s>"):format(ns.DisplayName(name), a.guild)
		if a.word == "P" then present[#present + 1] = row else busy[#busy + 1] = row end
	end
	for _ in pairs(summon.others or {}) do others = others + 1 end
	for _, elder in ipairs(EldersOnline()) do
		local answered = summon.answers[elder.name] or (summon.others and summon.others[elder.name])
		if not answered and elder.name ~= ns.me then silent[#silent + 1] = ("%s <%s>"):format(ns.DisplayName(elder.name), elder.guild) end
	end
	table.sort(present); table.sort(busy); table.sort(silent)
	return present, busy, silent, others
end

-- The mark next to an Elder or Council member in the Realm tree while a roll call is fresh: answered
-- present, busy, or (online) not answered yet.
function Shogun.RollCallMark(name, online)
	if not summon or not Shogun.CanCall() or ns.Now() - summon.t > Shogun.ROLL_SHOWN then return "" end
	local full = ns.FullName(name)
	if full == ns.me then return "" end -- who called
	local a = summon.answers[full]
	if a then return a.word == "P" and READY or NOT_READY end
	-- An answer the census could not confirm (counted apart) is still an answer: the mark only.
	local o = summon.others and summon.others[full]
	if o then return o == "P" and READY or NOT_READY end
	return online and WAITING or ""
end

local rollOpen = false
function Shogun.RollCallLines()
	if not Shogun.CanCall() then return {} end
	local present, busy, silent, others = RollCall()
	local lines = {
		{
			header = true, text = READY .. L.THRONE_SUMMON_TITLE,
			right = present and Grey(L.ROLL_COUNTS:format(#present, #busy, #silent) .. "  " .. ns.Ago(summon.t)) or Gold(L.ROLL_CALL),
			-- A call while there is none; once called, "call again" below (the results stay).
			onClick = not present and function() Shogun.Summon() end or nil,
			tooltip = function(tt)
				tt:AddLine(L.THRONE_SUMMON_TITLE, 1, 0.82, 0)
				tt:AddLine(L.THRONE_SUMMON_TIP, 1, 1, 1, true)
				tt:AddLine(L.ROLL_CLICK, 0.6, 0.6, 0.6, true)
			end,
		},
	}
	if present then
		lines[#lines + 1] = { indent = 1, text = Gold((rollOpen and "[-] " or "[+] ") .. L.ROLL_WHO),
			onClick = function()
				rollOpen = not rollOpen
				if ns.UI and ns.UI.Refresh then ns.UI.Refresh() end
			end }
		if rollOpen then
			for _, group in ipairs({ { L.THRONE_PRESENT_N, present, Green }, { L.THRONE_BUSY_N, busy, Grey }, { L.THRONE_SILENT_N, silent, Grey } }) do
				lines[#lines + 1] = { indent = 1, text = group[3](group[1]:format(#group[2])) }
				for _, row in ipairs(group[2]) do lines[#lines + 1] = { indent = 2, text = row } end
			end
			if others > 0 then lines[#lines + 1] = { indent = 1, text = Grey(L.THRONE_UNCONFIRMED:format(others)) } end
		end
		lines[#lines + 1] = { indent = 1, text = Gold("> " .. L.ROLL_AGAIN), onClick = function() Shogun.Summon() end }
	end
	lines[#lines].gapAfter = true
	return lines
end

-- The Royal Inspection on top of the Tabards tab: call one, then what the patrols reported.
function Shogun.InspectionLines()
	if not Shogun.CanCall() then return {} end
	local lines = {}
	local ok, bad, reporters, byGuild, names = 0, 0, 0, {}, {}
	for _, r in pairs(inspect and inspect.reports or {}) do
		reporters = reporters + 1
		ok, bad = ok + r.ok, bad + r.none + r.other
		local g = byGuild[r.guild] or { ok = 0, bad = 0 }
		g.ok, g.bad = g.ok + r.ok, g.bad + r.none + r.other
		byGuild[r.guild] = g
		for _, v in ipairs(r.names) do names[#names + 1] = v end
	end
	local total = ok + bad
	local pct = total > 0 and math.floor(ok * 100 / total + 0.5) or 0
	lines[1] = {
		header = true, text = "|TInterface\\Icons\\INV_Shirt_GuildTabard_01:14:14|t " .. L.THRONE_INSPECT_TITLE,
		right = inspect and Grey(L.INSPECTION_SHORT:format(pct, total) .. "  " .. ns.Ago(inspect.t)) or Gold(L.INSPECTION_CALL),
		onClick = not inspect and function() Shogun.Inspect() end or nil,
		tooltip = function(tt)
			tt:AddLine(L.THRONE_INSPECT_TITLE, 1, 0.82, 0)
			tt:AddLine(L.THRONE_INSPECT_TIP, 1, 1, 1, true)
		end,
	}
	if inspect then
		local left = inspect.t + Shogun.INSPECT_TIME + 10 - ns.Now()
		if left > 0 then lines[#lines + 1] = { indent = 1, text = Gold(L.THRONE_INSPECT_RUNNING:format(math.ceil(left))) } end
		lines[#lines + 1] = { indent = 1, text = L.THRONE_INSPECT_SUMMARY:format(reporters, total, pct) }
		local guilds = {}
		for guild, g in pairs(byGuild) do guilds[#guilds + 1] = { name = guild, ok = g.ok, n = g.ok + g.bad } end
		table.sort(guilds, function(a, b) return a.n > b.n end)
		for _, g in ipairs(guilds) do
			lines[#lines + 1] = { indent = 2, text = Green("<" .. g.name .. ">"),
				right = ("%d%%  (%d/%d)"):format(g.n > 0 and math.floor(g.ok * 100 / g.n + 0.5) or 0, g.ok, g.n) }
		end
		if #names > 0 then
			lines[#lines + 1] = { indent = 1, text = "|cffff4040" .. L.THRONE_VIOLATORS:format(#names) .. "|r" }
			for i, v in ipairs(names) do
				if i > 10 then
					lines[#lines + 1] = { indent = 2, text = Grey(L.AND_MORE:format(#names - 10)) }
					break
				end
				lines[#lines + 1] = { indent = 2, text = ("%s  %s"):format(v.name, Grey("<" .. v.guild .. ">")),
					right = v.status == "NONE" and L.TABARD_NONE or L.TABARD_OTHER }
			end
		end
		lines[#lines + 1] = { indent = 1, text = Gold("> " .. L.INSPECTION_AGAIN), onClick = function() Shogun.Inspect() end }
	end
	-- The untabarded list is the Shogun's: he alone lets the army see it (not a Hand), and can
	-- take it back at any time, inspection or not.
	if Shogun.IsShogun() or Shogun.Preview() then
		lines[#lines + 1] = { indent = 1, text = Gold("> " .. (Shogun.SharingUntabarded() and L.UNTABARDED_STOP or L.UNTABARDED_SHARE)),
			onClick = function() Shogun.ToggleUntabarded() end,
			tooltip = function(tt) tt:AddLine(L.UNTABARDED_TIP, 1, 1, 1, true) end }
	end
	lines[#lines].gapAfter = true
	return lines
end

local function HandsLines()
	local lines = Para({ Line(L.HANDS_TITLE, TITLE) }, L.HANDS_HINT, INK, { gapAfter = true })
	if Shogun.IsShogun() or Shogun.Preview() then
		lines[#lines + 1] = Line("+ " .. L.HANDS_ADD, TITLE, { onClick = function() ns.ShowDialog("BANKAIGUILD_SHOGUN_HAND") end })
		for _, name in ipairs(myHands) do
			lines[#lines + 1] = Line(ns.DisplayName(name), INK, { indent = 1, key = name,
				onClick = function() ns.ShowDialog("BANKAIGUILD_SHOGUN_UNHAND", ns.DisplayName(name), nil, name) end,
				tooltip = function(tt) tt:AddLine(ns.DisplayName(name), 1, 0.82, 0); tt:AddLine(L.HANDS_CLICK_REMOVE, 1, 1, 1, true) end })
		end
		if #myHands == 0 then lines[#lines + 1] = Line(L.HANDS_NONE, INK, { indent = 1 }) end
		lines[#lines].gapAfter = true
		Para(lines, L.HANDS_NOTE, INK)
	end
	return lines
end

Shogun.Line, Shogun.INK, Shogun.TITLE = Line, INK, TITLE

local function Go(mode) return function() Shogun.Show(mode) end end

-- The Throne Room: what is the Shogun's alone. Each tool lives where it belongs (the agenda and
-- the court on the buttons below, the roll call in the Realm, the inspection in the Tabards,
-- Poll and the treasury on their own tabs): here, the court's queue while it is open and
-- the treasury. A Hand's: where their tools are.
local function HomeLines()
	local mine = Shogun.IsShogun() or Shogun.Preview()
	local lines = { Line(mine and L.THRONE_ROOM or L.THRONE_ROOM_HAND:format(ns.ShogunName(handsShogun)), TITLE, { gapAfter = true }) }
	if not mine then return Para(lines, L.THRONE_HAND_HINT, INK) end
	for _, l in ipairs(ns.Court and ns.Court.HomeLines and ns.Court.HomeLines() or {}) do lines[#lines + 1] = l end
	if #lines > 1 then lines[#lines].gapAfter = true end
	for _, l in ipairs(ns.Treasury and ns.Treasury.ThroneLines and ns.Treasury.ThroneLines() or {}) do lines[#lines + 1] = l end
	return lines
end

-- The Shogun's own pages: a Hand's Throne Room has no link to them.
Shogun.SHOGUN_PAGES = { hands = true }

-- For Views.Build("throne"): lines, detail title, detail text.
-- The Shogun's Throne opens on the author's letter, its cover: the Throne Room (his court's
-- queue while it is open, the treasury) is a click away, and holding court takes him there.
-- A Hand's opens on the Throne Room.
function Shogun.Build(s)
	local lines, home
	local mine = Shogun.IsShogun() or Shogun.Preview()
	if not Shogun.mode then Shogun.mode = mine and "letter" or "home" end
	local mode = Shogun.mode
	if Shogun.SHOGUN_PAGES[mode] and not (Shogun.IsShogun() or Shogun.Preview()) then mode = "home" end
	if mode == "hands" then lines = HandsLines()
	elseif mode == "letter" then lines = Shogun.LetterLines()
	else lines, home = HomeLines(), true end
	-- Every other page leads back to the Throne Room (the letter also at its end).
	if not home then table.insert(lines, 1, Line("< " .. L.THRONE_ROOM, INK, { onClick = Go("home"), gapAfter = true })) end
	if mode == "letter" then
		lines[#lines].gapAfter = true
		lines[#lines + 1] = Line(L.THRONE_ENTER .. " >", TITLE, { onClick = Go("home") })
	end
	-- While the army sees him on the map, the page says so on top, whatever it shows.
	if Shogun.SharingLocation() and Shogun.IsShogun() then
		table.insert(lines, 1, Line("|T" .. ns.CROWN_ICON .. ":0|t " .. L.THRONE_LOCATION_LIVE, TITLE, { gapAfter = true }))
	end
	return lines, L.TAB_THRONE, Shogun.IsHand() and L.THRONE_YOU_ARE_HAND:format(ns.ShogunName(handsShogun)) or L.THRONE_YOU_ARE_SHOGUN
end

function Shogun.Show(mode)
	-- Leaving the letter for another page: read.
	if Shogun.mode == "letter" and mode ~= "letter" and (Shogun.IsShogun() or Shogun.Preview()) then ns.db.throneLetterRead = true end
	Shogun.mode = mode
	Changed()
end

-- For tests.
function Shogun.CancelAgendaButton()
	if not Shogun.Agenda() then return ns.Print(L.THRONE_AGENDA_NONE) end
	Shogun.CancelAgenda()
	ns.Print(L.THRONE_AGENDA_CANCELLED)
end

function Shogun.State() return { summon = summon, inspect = inspect, agenda = agenda, inspecting = inspecting } end

-- The author's Workshop: Shobek's view on or off (the Throne, Poll, the Shogun's calls in
-- the Realm and the Tabards), to see and try them. Nothing the view does reaches anyone.
function Shogun.SetDevView(on)
	ns.db.devShogunView = on and true or false
	-- The preview's treasury switches were its own: gone with it.
	if not on then ns.db.previewTreasuryFlags = nil end
	ns.Print(on and L.DEV_SHOGUN_VIEW_NOW_ON or L.DEV_SHOGUN_VIEW_NOW_OFF)
	ns.Fire("DATA_CHANGED")
	Changed()
end
function Shogun.Reset()
	summon, inspect, agenda, inspecting, shogunAt, crownAt = nil, nil, nil, nil, nil, nil
	hands, handsAt, lastHandsSent, handsShogun, handsSendPending = {}, -math.huge, -math.huge, nil, false
	wipe(myHands)
	lastLocation = { t = -math.huge }
	lastSummonSeen, lastInspectSeen, lastSummonSent, lastInspectSent = -math.huge, -math.huge, -math.huge, -math.huge
	lastUntabardedSent = -math.huge
	lastAgendaSent, lastAgendaWarn, changePending = -math.huge, -math.huge, false
	Shogun.mode, rollOpen = nil, false
end
