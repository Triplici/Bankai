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
--   T1~N~<id>~<guild>~<Name-Realm,...>     a Steward's own Hands (1.0.0: his alone; resent every 5 min)
--   T2~<id>~<P|B>~<guild>                  an Elder's answer to the roll call
--   T3~<id>~<guild>~<ok>~<none>~<other>~<name:guild,...>   an inspection report
-- Other modules add their own kinds (Shogun.Register): Poll (V, E), writs (W), the court
-- (C, Z), the gates (G), pardons (F), the treasury's switches and keepers (T, K: his and his
-- Steward's), the Shogun's week and its signup sheet (D, R, 1.1: Week.lua), the dues' weekly
-- amount (Y, 1.1: his and his Steward's, Dues.lua).
-- The Shogun's Steward (1.0.0, ns.IsSteward: the character the author marks in the signed titles
-- list) has the Throne as the Shogun has it, "acting for the Shogun": he names and removes Hands of
-- his own beside the Shogun's, the treasury's keepers and its switches, and uses every tool of a
-- Hand (STEWARD_MAY). Never the Shogun's own list of Hands, his crown on the map and his layer, the
-- court, writs, pardons, the untabarded list, or the Shogun's own book of the treasury and his yes
-- to share it.

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
-- (1.2.4, the author's ask: lists of people are not erased; provisional, his to confirm) A list the
-- Shogun (or a Steward) gave stands until his newer one, kept in the saved data across a /reload:
-- before, it ended this long after his client stopped repeating it (he logged out), so his Hands
-- lost the Throne's tools on every client 20 minutes after he left. Kept for the older builds' word.
Shogun.HANDS_FRESH = 20 * 60

Shogun.mode = nil              -- what the tab shows: home or hands (nil: home, the Throne Room)
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

-- Someone we can place: our own guild (the server's roster) or an Elder or Council member. Before signed
-- enforcement this keeps the old roster/census decision exactly; afterwards a local roster role
-- is valid only for its actual guild and each cross-guild role comes from the manifest.
local function Verified(sender, guild)
	local enforcing = ns.Authority and ns.Authority.Enforced and ns.Authority.Enforced()
	if not enforcing and ns.Roster.RankOf(sender) then return true end
	local rank = guild and ns.Data.AuthorizedRank(sender, guild)
	return rank ~= nil and rank <= ns.COUNCIL_MEMBER_RANK
end

---------------------------------------------------------------------------
-- Who
---------------------------------------------------------------------------

-- Where the Shogun is pinned by name, another guild master of his guild is not him: nobody
-- would obey the powers the Throne gave that character. (1.3.4) Nor where the author's signed
-- launch list reaches and names no Shogun for our side yet (ns.LaunchListHeld): on a launch realm group the
-- first to found a guild of that name is nobody's Shogun.
function Shogun.IsShogun()
	if not ns.IsMember() then return false end
	local guild, _, rank = GetGuildInfo("player")
	if not (ns.IsShogunGuild(guild) and rank == 0) then return false end
	return (ns.ShogunCharacter() == nil and not ns.LaunchListHeld()) or ns.IsShogunCharacter(ns.me)
end

-- The author's test build (Dev.lua, never published) shows the tab without the powers:
-- nothing it does reaches anyone. The author turns this "Shobek's view" on and off from the
-- Workshop (ns.db.devShogunView).
function Shogun.Preview()
	if Shogun.IsShogun() then return false end
	if ns.ViewAs and ns.ViewAs.Is and ns.ViewAs.Is("shogun") then return true end
	if ns.ViewAs and ns.ViewAs.Previewing and ns.ViewAs.Previewing() then return false end
	local view = ns.db and ns.db.devShogunView
	if view ~= nil and ns.Workshop and ns.Workshop.Visible and ns.Workshop.Visible() then return view == true end
	local dev = ns.devThrone
	if type(dev) == "table" then dev = dev[UnitName and UnitName("player") or ""] == true or dev[ns.ShortName(ns.me or "")] == true end
	return dev == true and not Shogun.IsShogun()
end
function Shogun.Visible() return Shogun.IsShogun() or Shogun.IsSteward() or Shogun.IsHand() or Shogun.Preview() end

-- 1.1.5 (the author's call): the tab in the Throne's place is the Throne for the Shogun's people
-- (the Shogun, his Steward, his Hands, the Shogun preview, and the High Council: 1.2.4, the Shogun's
-- centurions, Nominees.lua), and a guild master's Guild tab for the guild master of
-- another Bankai Guild guild (his centurions and correspondents). Under the author's guild master's
-- view (Nominees.DevView), the Guild tab alone: it shows what a guild master sees.
function Shogun.ThroneShown()
	local N = ns.Nominees
	if N and N.DevView and N.DevView() then return false end
	-- (1.2: the author's High Council preview, ViewAs.lua, is the council's Throne Room, as Shobek's
	-- view is the Shogun's through Shogun.Preview.)
	local V = ns.ViewAs
	if type(V) == "table" and type(V.Is) == "function" and V.Is("councillor") then return true end
	return Shogun.Visible() or (ns.IsMember() == true and ns.IsHighCouncillor(ns.me) == true)
end
function Shogun.GuildShown()
	local N = ns.Nominees
	if N and not N.missing and N.GuildAccess then return N.GuildAccess() == true end
	return N ~= nil and not N.missing and N.IsMaster ~= nil and N.IsMaster() == true
end
function Shogun.TabVisible() return Shogun.ThroneShown() or Shogun.GuildShown() end
-- The tab's name (a locale key): the Throne's, or the Guild tab's (UI.lua relabels it).
function Shogun.TabLabel() return (Shogun.ThroneShown() or not Shogun.GuildShown()) and "TAB_THRONE" or "TAB_GUILD" end

-- The Shogun's Steward (1.0.0): this character, where the signed titles list marks it for our
-- Shogun (ns.IsSteward), and not the Shogun himself.
function Shogun.IsSteward() return not Shogun.IsShogun() and ns.IsSteward(ns.me) end
-- A sender the list marks (the server sets the name): his word counts for what STEWARD_MAY lends.
function Shogun.IsStewardName(name) return type(name) == "string" and not ns.IsShogunCharacter(name) and ns.IsSteward(name) end

-- The Shogun himself, or his Steward: the lists of the Throne are theirs to set (each his own list
-- of Hands; the treasury's keepers and switches), and their clients repeat them.
function Shogun.SetsLists() return Shogun.IsShogun() or Shogun.IsSteward() end

-- Where the Shogun is pinned by name (ns.SHOGUN_CHARACTER): that character alone, speaking for
-- the Shogun's guild. No census vote can crown anyone else, nor silence him. Where he is not
-- (the Horde, until his name is known) nobody's commands are obeyed; soft: what only shows
-- (his position, his name on the lines) still comes from the census there (Data.KnownRank).
local function ShogunSender(sender, guild, soft)
	if not ns.IsShogunGuild(guild) then return false end
	if ns.ShogunCharacter() then
		if not ns.IsShogunCharacter(sender) then return false end
		ns.LearnShogunRealm(sender) -- (the Horde's, while unknown: from the server's name)
		if ns.Hop and ns.Hop.HeardShogun then ns.Hop.HeardShogun(sender) end -- (his realm: his own word, 1.0.0)
		return true
	end
	return soft == true and not ns.LaunchListHeld() and ns.Data.KnownRank(sender, guild, true) == 0
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

-- kind: the alert's sound switch (1.1, ns.SOUND_KINDS). o (1.1, ns.Alert): its popup or window
-- (show), how long it is current (open), its words while it waits (what), one line for the
-- same one repeated (key), the player's own click (own). The chat line always comes now; the
-- raid warning, the sound and the popup wait in an instance or on Busy.
local function Warn(text, loud, kind, o)
	ns.Print("|cffffd200" .. text .. "|r")
	o = o or {}
	return ns.Alert(kind or "throne", loud and "loud" or "soft", { text = text, color = { r = 1, g = 0.82, b = 0 },
		what = o.what, open = o.open, show = o.show, key = o.key, own = o.own })
end

local function NewId() return math.random(1, 99999) end

---------------------------------------------------------------------------
-- The Hands of the Shogun: the players he names use the Throne's tools in his name (HAND_MAY:
-- the roll call, the inspection, the agenda, Poll, the gates), never what is his alone
-- (the Hands, writs, the court, pardons, his position). Each client keeps the list of the
-- Shogun it trusts, as he last sent it (1.2.4: in its saved data, until his newer list, while he is
-- the Shogun; a list he stopped repeating ended after HANDS_FRESH before).
-- 1.0.0: each of his Stewards names Hands too, in a list of his own that only his client sends
-- (T1~N, STEWARD_MAY; clients before 1.0.0 know no such kind and leave it out):
--   T1~N~<id>~<guild>~<Name-Realm,...>     a Steward's Hands (his alone; resent every 5 min)
-- The Hands are the Shogun's list and every Steward's together, each list its owner's alone:
-- nobody changes anyone else's. The Shogun's list is the same message as before 1.0.0, from his
-- client alone. Each client keeps the list it last heard from each Steward (by his name, which
-- the server stamps) until his newer list (1.2.4; it ended HANDS_FRESH after his client stopped
-- repeating it before), and at once, on every client, when the author's signed titles list no
-- longer names him (for good: named again,
-- he starts from none, Shogun.StewardsChanged). A Hand's powers are the same whoever named him.
-- The Shogun never removes a Steward's Hand: that Steward does, or the author, by removing him
-- (the Hands page shows the others' lists, to read only).
---------------------------------------------------------------------------

Shogun.HAND_MAY = { S = true, I = true, A = true, X = true, V = true, E = true, G = true }
-- The Steward's: everything a Hand may, his own list of Hands (N), and the treasury's switches
-- and keepers (T, K, Treasury.lua), and its dues' amount (Y, 1.1, Dues.lua). Never the Shogun's
-- list of Hands (H), his crown on the map (P, Q), the court (C, Z), writs (W), pardons (F) or the
-- untabarded list (U).
Shogun.STEWARD_MAY = { S = true, I = true, A = true, X = true, V = true, E = true, G = true, N = true, T = true, K = true, Y = true }
-- 1.1: the calls to the army a Hand or a Steward sends (popups, raid warnings, windows, the gates'
-- news): none shows from a name the moderators took off (net-off, Moderation.lua). Their lists (the
-- Hands, the treasury's words) are not calls: they still count. The same for the Shogun's week (1.1,
-- Konig's review): its entries and their cancels (D), and the signup sheets (R, Week.lua). A client
-- the moderators took off sends none of them (Moderation.Blocks), but its setter's cancel of his
-- own entry, which every client takes for that entry alone (1.1 review).
Shogun.HIDDEN_CALLS = { S = true, I = true, A = true, X = true, V = true, E = true, G = true, D = true, R = true }
-- A word of the treasury (its switches, its keepers: Treasury.lua) dated further ahead of the
-- server's clock is not taken. A minute: every client reads the same server clock, so a word
-- dated further ahead comes from a modified client, which would otherwise keep its word over
-- the Shogun's newer one for as long (a review asked for a minute, not ten).
Shogun.DATE_AHEAD = 60

local hands = {}         -- [name-realm, lower case] = true, as the Shogun last sent it
local handsOrder = {}    -- the same names, in his order (the Hands page)
local handsAt = -math.huge
local handsShogun          -- who sent that list (the Shogun's name on a Hand's Throne Room)
local myHands = {}       -- the Shogun's own list, in order: { "Name-Realm", ... } (saved: rdb.shogunHands)
local lastHandsSent = -math.huge
local handsSendPending = false
-- 1.0.0: each Steward's list as this client last heard it from him:
-- [his Name-Realm] = { names = { "Name-Realm", ... }, set = { [name-realm, lower case] = true }, at = when }
-- (1.2.4: the Shogun's list heard and each Steward's are kept in the saved data too, rdb.handsHeard =
-- { names, at, shogun } and rdb.stewardHandsHeard[his Name-Realm] = { names, at }: Shogun.LoadHands.)
local stewardHands = {}
-- A Steward's own list, on his client, in order (saved: rdb.stewardHands[his Name-Realm]: the
-- characters of one account on a realm group share what they save).
local myStewardHands = {}
local lastStewardSent = -math.huge

-- A Steward's list as heard here, while it counts: he is still a Steward (the signed titles
-- list names him). (1.2.4: until his newer list, whether his client still repeats it or not.)
local function StewardList(steward)
	local s = stewardHands[steward]
	if not s or not Shogun.IsStewardName(steward) then return nil end
	return s
end

-- On the Shogun's own client his list is the one he keeps (his broadcast never comes back to
-- him); everyone else trusts the list he last sent, while he keeps sending it. A Steward's
-- the same (1.0.0): his own on his client, the one he last sent on everyone else's.
-- Whatever the case a name is written in (1.1, Konig's review): the Shogun types a Hand's name as
-- he likes, and a net-off word's target is free text, while the server spells a sender's name
-- its own way; they are one character (hands and each Steward's set are kept in lower case).
local function Named(list, key)
	for _, n in ipairs(list) do if type(n) == "string" and n:lower() == key then return true end end
	return false
end
-- (1.2.4) The Shogun's list as heard here counts while its sender is the Shogun: kept until his
-- newer list, never past his reign (an update naming another Shogun).
local function HeardShogun() return type(handsShogun) == "string" and ns.IsShogunCharacter(handsShogun) end
local function Hand(name)
	local full = ns.FullName(name)
	if type(full) ~= "string" then return false end
	local key = full:lower()
	if Shogun.IsShogun() then
		if Named(myHands, key) then return true end
	elseif hands[key] == true and HeardShogun() then
		return true
	end
	if Shogun.IsSteward() and Named(myStewardHands, key) then return true end
	for steward in pairs(stewardHands) do
		local s = StewardList(steward)
		if s and s.set[key] then return true end
	end
	return false
end

function Shogun.IsHand() return not Shogun.SetsLists() and ns.IsMember() and Hand(ns.me) end
-- 1.2.4 (Bank.lua): the Shogun's list is heard here now (he keeps repeating it), so that IsHand's
-- false says this character is no Hand of his, not only that his list is not heard (he left).
function Shogun.HandsFresh() return Shogun.IsShogun() or ns.Now() - handsAt <= Shogun.HANDS_FRESH end
-- Whether the Shogun's list or a Steward's names this sender (1.0.0): their word alone, never a
-- census vote. His Hands speak with his Crown for his guild on every client outside it
-- (Decree.lua, Channels.VerifiedLevel); on its own members' clients its roster says who speaks
-- for it.
function Shogun.IsHandName(name) return type(name) == "string" and Hand(name) end

-- This client's own list, the one its Hands page changes: the Shogun's; a Steward's own (1.0.0);
-- the author's Shobek's view's, as the Shogun's (sent nowhere).
local function Own()
	if not Shogun.IsShogun() and Shogun.IsSteward() then return myStewardHands end
	return myHands
end
function Shogun.Hands() return Own() end

-- A Steward's name as the Shogun's screen shows it: cut short while the council's names are hidden
-- there (his stream, ns.CouncilMasked), like every councillor's.
local function StewardLabel(name)
	local shown = ns.DisplayName(name) or "?"
	return ns.CouncilMasked() and ns.MaskName(shown) or shown
end
Shogun.StewardLabel = StewardLabel

-- The others' lists this client's Hands page shows, to read only (1.0.0): the Shogun's (on a
-- Steward's client), then each Steward's but its own, while they count, none empty:
-- { { steward = <Name-Realm, nil for the Shogun's>, names = { ... } }, ... }
function Shogun.OthersHands()
	local out = {}
	if not Shogun.IsShogun() and #handsOrder > 0 and HeardShogun() then
		out[1] = { names = handsOrder }
	end
	local names = {}
	for steward in pairs(stewardHands) do
		local s = StewardList(steward)
		if s and #s.names > 0 and not (Shogun.IsSteward() and steward == ns.FullName(ns.me)) then names[#names + 1] = steward end
	end
	table.sort(names)
	for _, steward in ipairs(names) do out[#out + 1] = { steward = steward, names = stewardHands[steward].names } end
	return out
end

-- The Shogun may send it; a Steward what STEWARD_MAY lends him (his own list of Hands among it:
-- never a list of the Shogun's); one of their Hands what is theirs to use too (soft: his
-- position).
-- (1.4.0, the owner's rule for the launch: the Shogun does not work these switches) What the addon's
-- author may do though he is never the Shogun nor a Steward: the Treasury ranking's switch alone among
-- the Throne's words (T1~r, Treasury.lua), and the Games tab's rankings' publish word (ArenaRoles,
-- "rankings": the arena's files name no author, so they ask here). One of his characters as Core.lua's
-- signed list names them (ns.IsAuthorName), never a role he previews.
Shogun.AUTHOR_MAY = { r = true, rankings = true }
function Shogun.AuthorMay(what, name)
	return Shogun.AUTHOR_MAY[what] == true and type(name) == "string" and name ~= "" and ns.IsAuthorName(ns.FullName(name)) == true
end
function Shogun.Authorized(kind, sender, guild)
	if Shogun.AUTHOR_MAY[kind] == true then return Shogun.AuthorMay(kind, sender) end
	if ShogunSender(sender, guild, kind == "P" or kind == "Q") then return true end
	if Shogun.STEWARD_MAY[kind] == true and Shogun.IsStewardName(sender) then return true end
	return Shogun.HAND_MAY[kind] == true and Hand(sender)
end

-- The Shogun, his Steward, or a Hand: the tools of the Throne.
function Shogun.CanCommand()
	if Shogun.IsShogun() then return true end
	-- (1.1.6: a sanctioned Steward or Hand has none of the Throne's tools while it lasts.)
	local WC = ns.WatchChat
	if WC and not WC.missing and WC.Barred and WC.Barred("powers") then return false end
	return Shogun.IsSteward() or Shogun.IsHand()
end

-- 1.2.4: the Agenda is Heraldry's. A title or a Crown duty alone grants no posting power.
-- Army: the existing verified Shogun/Steward/Hand roots, the author, or a signed councillor of
-- Heraldry (the old signed name remains readable). Guild: its own live-roster master or his
-- verified Heraldry correspondent. A guild master alone never gains army authority.
function Shogun.AgendaAuthorized(name, guild, guildOnly)
	if type(name) ~= "string" or not ns.IsMember() then return false end
	local WC, M = ns.WatchChat, ns.Moderation
	if M and M.Hides and M.Hides(name, guild) then return false end
	if WC and not WC.missing and WC.Barred and WC.Barred("powers", name) then return false end
	if guildOnly then
		local mine, _, rank = GetGuildInfo("player")
		if type(guild) ~= "string" or guild ~= mine then return false end
		if ns.FullName(name) == ns.FullName(ns.me) and rank == 0 then return true end
		local R = ns.Roster
		local roster = R and R.Fresh and R.Fresh()
		if roster and roster.guild == guild and R.RankOf and R.RankOf(ns.FullName(name)) == 0 then return true end
		local N = ns.Nominees
		return N and not N.missing and N.IsCorrespondent and N.IsCorrespondent(name, guild, "Department of Heraldry") == true or false
	end
	if ns.IsShogunCharacter(name) then return true end
	if Shogun.Authorized("A", name, guild) then return true end
	local W = ns.Workshop
	if W and W.IsAuthorName and W.IsAuthorName(name) then return true end
	if ns.IsHighCouncillor(name) ~= true then return false end
	local title = ns.CouncilTitle and ns.CouncilTitle(name)
	local dept = title and title.dept
	local N = ns.Nominees
	if N and N.DepartmentName then dept = N.DepartmentName(dept) end
	return dept == "Department of Heraldry"
end

function Shogun.AgendaScope(scope)
	if scope ~= nil then return (scope == "guild" or scope == "army") and scope or nil end
	if Shogun.AgendaAuthorized(ns.me, GetGuildInfo("player"), false) or Shogun.Preview() then return "army" end
	return "guild"
end
function Shogun.AgendaPreviewBlocked()
	local V = ns.ViewAs
	return V and V.Previewing and V.Previewing() and not Shogun.Preview() or false
end
function Shogun.CanAgenda(scope)
	if Shogun.AgendaPreviewBlocked() then return false end
	scope = Shogun.AgendaScope(scope)
	return scope ~= nil and (Shogun.Preview() or Shogun.AgendaAuthorized(ns.me, GetGuildInfo("player"), scope == "guild"))
end

-- The Shogun himself sent it (not a Hand): for how it is shown.
function Shogun.FromShogun(sender, guild) return ShogunSender(sender, guild, true) end

-- The Shogun's list, kept across sessions (a /reload must not drop his Hands); a Steward's own
-- the same (1.0.0), under his name: it ends with him (Shogun.StewardsChanged), whichever character
-- of his account on that realm group sees the list without him.
local function SaveHands()
	if not ns.rdb then return end
	local own, copy = Own(), {}
	for i, n in ipairs(own) do copy[i] = n end
	if own ~= myStewardHands then ns.rdb.shogunHands = copy; return end
	if type(ns.rdb.stewardHands) ~= "table" then ns.rdb.stewardHands = {} end
	ns.rdb.stewardHands[ns.FullName(ns.me)] = copy
end

-- Several changes in a row go out as one list, a few seconds after the last one.
local function SendHandsSoon()
	if handsSendPending then return end
	handsSendPending = true
	ns.After(3, "shogun hands", function()
		handsSendPending = false
		Shogun.SendHands(true)
		Shogun.SendStewardHands(true)
	end)
end

-- Quiet presence (1.2.5.1, Core.lua): the lists the Shogun's (or a Steward's) client repeats for late
-- logins (his Hands, the untabarded, the agenda) are not repeated while it is on: each repeat says
-- he is online, and the army's copy lapses as after a logout (HandsFresh). A list he changes, or a
-- switch he turns, still goes (force); the repeats come back once it is off.
local function QuietRepeat(force) return not force and ns.QuietPresence ~= nil and ns.QuietPresence() == true end
Shogun.QuietRepeat = QuietRepeat

-- The Shogun's list goes out whole: short in one message, long in pieces (Comm.SendChunked).
function Shogun.SendHands(force)
	if not Shogun.IsShogun() or QuietRepeat(force) then return end
	local now = ns.Now()
	if not force and now - lastHandsSent < Shogun.HANDS_EVERY then return end
	-- (nobody named yet; 1.2.4: a list he emptied is said again, empty, at his later sessions:
	-- every client keeps the list it heard until his newer one, SaveHands' rdb.shogunHands)
	if #myHands == 0 and lastHandsSent == -math.huge and type(ns.rdb and ns.rdb.shogunHands) ~= "table" then return end
	lastHandsSent = now
	local msg = ("T1~H~%d~%s~%s"):format(NewId(), GetGuildInfo("player") or "", table.concat(myHands, ","))
	if #msg <= 250 then ns.Comm.Send("CHANNEL", msg, "hands") else ns.Comm.SendChunked(msg) end
end

-- A Steward's own list (1.0.0), from his client alone, the same way.
function Shogun.SendStewardHands(force)
	if Shogun.IsShogun() or not Shogun.IsSteward() or QuietRepeat(force) then return end
	local now = ns.Now()
	if not force and now - lastStewardSent < Shogun.HANDS_EVERY then return end
	-- (nobody named yet; 1.2.4: a list he emptied is said again, empty, the Shogun's way)
	local saved = ns.rdb and type(ns.rdb.stewardHands) == "table" and ns.rdb.stewardHands[ns.FullName(ns.me)]
	if #myStewardHands == 0 and lastStewardSent == -math.huge and type(saved) ~= "table" then return end
	lastStewardSent = now
	local msg = ("T1~N~%d~%s~%s"):format(NewId(), GetGuildInfo("player") or "", table.concat(myStewardHands, ","))
	if #msg <= 250 then ns.Comm.Send("CHANNEL", msg, "stewardhands") else ns.Comm.SendChunked(msg) end
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

-- The Shogun names a Hand in his list, a Steward in his own (1.0.0).
function Shogun.AddHand(input)
	if not Shogun.SetsLists() and not Shogun.Preview() then return ns.Print(L.THRONE_ONLY_SHOGUN) end
	local name = HandName(input)
	if not name then return ns.Print(L.HANDS_WHO) end
	if name == ns.me then return end
	local own = Own()
	for _, n in ipairs(own) do if n == name then return end end
	if #own >= Shogun.MAX_HANDS then return ns.Print(L.HANDS_FULL:format(Shogun.MAX_HANDS)) end
	own[#own + 1] = name
	SaveHands()
	ns.Print(L.HANDS_ADDED:format(ns.DisplayName(name)))
	if Shogun.SetsLists() then SendHandsSoon() end
	Shogun.mode = "hands"
	Changed()
end

-- From this client's own list alone: never a Hand another one named (1.0.0).
function Shogun.RemoveHand(name)
	local own = Own()
	for i, n in ipairs(own) do
		if n == name then
			table.remove(own, i)
			SaveHands()
			ns.Print(L.HANDS_REMOVED:format(ns.DisplayName(name)))
			if Shogun.SetsLists() then SendHandsSoon() end
			return Changed()
		end
	end
end

-- This client became a Hand (the Throne's tab appears; `told`: by whom), or is one no more.
local function HandChanged(was, told)
	local now = Shogun.IsHand()
	if now and not was then
		ns.Print(told())
		ns.PlayAlert("soft", "throne")
		ns.Fire("DATA_CHANGED") -- the Throne's tab appears
	elseif was and not now then
		ns.Fire("DATA_CHANGED")
	end
	Changed()
end

local function OnHands(shogun, rest)
	local list, n, order = {}, 0, {}
	for name in tostring(rest or ""):gmatch("[^,]+") do
		local short = CleanName(name)
		if short and n < Shogun.MAX_HANDS then
			local full = ns.FullName(short, ns.RealmOf(name))
			if not list[full:lower()] then order[#order + 1] = full end
			list[full:lower()] = true
			n = n + 1
		end
	end
	local was = Shogun.IsHand()
	hands, handsOrder, handsAt, handsShogun = list, order, ns.Now(), ns.FullName(shogun)
	-- (1.2.4) Kept until his newer list (Shogun.LoadHands).
	if ns.rdb then ns.rdb.handsHeard = { names = order, at = handsAt, shogun = handsShogun } end
	HandChanged(was, function() return L.HANDS_YOU:format(ns.ShogunName(shogun)) end)
end

-- A Steward's own list (1.0.0), from his own client: kept as he last sent it. Nobody else's
-- word (the Shogun's character sending one too: Shogun.Authorized lets him send any kind).
local function OnStewardHands(sender, rest)
	if not Shogun.IsStewardName(sender) then
		return ns.Log("steward hands from %s ignored: no Steward here", tostring(sender))
	end
	local steward = ns.FullName(sender)
	local names, set = {}, {}
	for name in tostring(rest or ""):gmatch("[^,]+") do
		local short = CleanName(name)
		local full = short and ns.FullName(short, ns.RealmOf(name))
		if full and not set[full:lower()] and #names < Shogun.MAX_HANDS then
			set[full:lower()] = true
			names[#names + 1] = full
		end
	end
	local was = Shogun.IsHand()
	stewardHands[steward] = { names = names, set = set, at = ns.Now() }
	-- (1.2.4) Kept until his newer list (Shogun.LoadHands).
	if ns.rdb then
		if type(ns.rdb.stewardHandsHeard) ~= "table" then ns.rdb.stewardHandsHeard = {} end
		ns.rdb.stewardHandsHeard[steward] = { names = names, at = ns.Now() }
	end
	HandChanged(was, function() return L.HANDS_YOU_STEWARD:format(ns.DisplayName(steward) or "?") end)
end

-- The lists this client kept, at login: the Shogun's (as before 1.0.0) and a Steward's own.
function Shogun.LoadHands()
	local function Load(into, saved)
		wipe(into)
		for _, n in ipairs(type(saved) == "table" and saved or {}) do
			if type(n) == "string" and #into < Shogun.MAX_HANDS then into[#into + 1] = n end
		end
	end
	Load(myHands, ns.rdb and ns.rdb.shogunHands)
	local stewards = ns.rdb and ns.rdb.stewardHands
	Load(myStewardHands, type(stewards) == "table" and stewards[ns.FullName(ns.me)])
	-- (1.2.4) The lists heard from the Shogun and each Steward, standing until their newer word.
	local function Names(list)
		local names, set = {}, {}
		for _, n in ipairs(type(list) == "table" and list or {}) do
			local short = type(n) == "string" and CleanName(n)
			local full = short and ns.FullName(short, ns.RealmOf(n))
			if full and not set[full:lower()] and #names < Shogun.MAX_HANDS then set[full:lower()], names[#names + 1] = true, full end
		end
		return names, set
	end
	local heard = ns.rdb and ns.rdb.handsHeard
	if type(heard) == "table" and type(heard.shogun) == "string" then
		local names, set = Names(heard.names)
		hands, handsOrder, handsAt, handsShogun = set, names, tonumber(heard.at) or ns.Now(), heard.shogun
	end
	wipe(stewardHands)
	for steward, x in pairs(ns.rdb and type(ns.rdb.stewardHandsHeard) == "table" and ns.rdb.stewardHandsHeard or {}) do
		if type(steward) == "string" and type(x) == "table" then
			local names, set = Names(x.names)
			stewardHands[steward] = { names = names, set = set, at = tonumber(x.at) or ns.Now() }
		end
	end
end

-- A signed titles list was taken (Workshop.TakeTitles, 1.0.0): the list of each Steward it no
-- longer names ends here for good, as heard from him and as his account kept it, his own
-- client's with it. Named again later, a Steward starts from none: nothing he named before comes
-- back until he names it again. (His account forgets it when one of its characters on that realm
-- group takes a list without him: if none did before the list naming him again, what it kept
-- comes back with him.)
function Shogun.StewardsChanged()
	local changed = false
	for steward in pairs(stewardHands) do
		if not Shogun.IsStewardName(steward) then stewardHands[steward], changed = nil, true end
	end
	local saved = ns.rdb and ns.rdb.stewardHands
	if type(saved) == "table" then
		for owner in pairs(saved) do
			if not Shogun.IsStewardName(owner) then saved[owner] = nil end
		end
		if next(saved) == nil then ns.rdb.stewardHands = nil end
	end
	local heard = ns.rdb and ns.rdb.stewardHandsHeard
	if type(heard) == "table" then
		for owner in pairs(heard) do
			if not Shogun.IsStewardName(owner) then heard[owner] = nil end
		end
		if next(heard) == nil then ns.rdb.stewardHandsHeard = nil end
	end
	if not Shogun.IsSteward() and (#myStewardHands > 0 or lastStewardSent ~= -math.huge) then
		wipe(myStewardHands)
		lastStewardSent, changed = -math.huge, true
	end
	if changed then Changed() end
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
Shogun.Warn = function(text, loud, kind, o) return Warn(text, loud, kind, o) end
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
	-- The Shogun by the army's name for him; a Hand by theirs.
	local who = Shogun.FromShogun(shogun, guild) and L.THRONE_SUMMONED:format(ns.ShogunName(shogun)) or L.THRONE_SUMMONED_HAND:format(ns.DisplayName(shogun))
	-- In an instance or on Busy (1.1): a chat line; the popup once the player is out, while it
	-- is open (never answered for them).
	local shown = ns.Alert("throne", "soft", {
		what = L.HELD_SUMMON, key = "summon" .. tostring(id),
		open = function() return ns.Now() - now < Shogun.SUMMON_OPEN end,
		show = function() ns.ShowDialog("BANKAIGUILD_SHOGUN_SUMMON", who, nil, { shogun = shogun, id = id }) end,
	})
	if not shown then ns.Print("|cffffd200" .. who .. "|r  |cff9d9d9d" .. L.HELD_LATER .. "|r") end
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

-- Its raid warning, in an instance or on Busy (1.1, ns.Alert): current while the patrols run.
-- own: the Shogun's (or the preview's) own click.
function Shogun.InspectionHeld(start, id, own)
	return { what = L.HELD_INSPECTION, key = "inspect" .. tostring(id or 0), own = own or nil,
		open = function() return ns.Now() - start < Shogun.INSPECT_TIME end }
end

-- Every addon (the Shogun's too): a raid warning, a patrol of INSPECT_TIME, then a report to
-- the Shogun of what it saw (and our own tabard).
function Shogun.RunInspection(shogun, id)
	if inspecting or not ns.IsMember() then return end
	local start = ns.Now()
	inspecting = { shogun = shogun, id = id, start = start, wasOn = ns.Inspect.IsPatrolling() }
	Warn(L.THRONE_INSPECT_WARN, true, "throne", Shogun.InspectionHeld(start, id, shogun == nil or shogun == ns.me))
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
		-- What another officer of our guild found (1.1, Inspect.lua) is his word, not ours: left out.
		for name, p in pairs(ns.Inspect.Players()) do
			if not p.shared and (p.t or 0) >= run.start - 600 then
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
	-- a player who said no (/bk inspection off, 0.9.3). 1.1 (Fern's #11): nor one who never
	-- answered (the first-open page, or /bk inspection on): nil is off.
	if not (ns.db and ns.db.royalInspection == true) then
		ns.Log("inspection %d: not taking part (%s)", id or 0, ns.db and ns.db.royalInspection == false and "/bk inspection off" or "not answered")
		return Warn(L.THRONE_INSPECT_WARN, true, "throne", Shogun.InspectionHeld(now, id))
	end
	if Shogun.random() > Shogun.InspectShare() then
		ns.Log("inspection %d: not in this sample (%.2f)", id or 0, Shogun.InspectShare())
		return Warn(L.THRONE_INSPECT_WARN, true, "throne", Shogun.InspectionHeld(now, id))
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
Shogun.UNTABARDED_EVERY = 8 * 60 -- shorter than the 10-minute publication lease
local lastUntabardedSent = -math.huge

function Shogun.SharingUntabarded() return ns.db and ns.db.shogunUntabarded == true end

-- What the inspection's patrols reported joins his own list.
local function TakeReports()
	for _, r in pairs(inspect and inspect.reports or {}) do
		for _, v in ipairs(r.names) do ns.Inspect.AddReported(v.name, v.guild, v.status) end
	end
end

function Shogun.SendUntabarded(force)
	if not Shogun.IsShogun() or QuietRepeat(force) then return end
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
	-- 1.1 (#12): his own switch never comes back to him: in his log as he sends it.
	local on = Shogun.SharingUntabarded()
	ns.Chronicle.Add("switch", ns.me, on and L.ACTS_UNTABARDED_ON or L.ACTS_UNTABARDED_OFF, { key = "untabarded", value = on and "1" or "0" })
	Changed()
end

local function OnUntabarded(sender, rest)
	if Shogun.IsShogun() then return end
	local on, body = tostring(rest or ""):match("^(%d)~?(.*)$")
	-- 1.1 (#12): in this client's log of acts when it flips (repeated every 5 minutes while on).
	if on == "1" or on == "0" then
		ns.Chronicle.Add("switch", sender, on == "1" and L.ACTS_UNTABARDED_ON or L.ACTS_UNTABARDED_OFF, { key = "untabarded", value = on })
	end
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

function Shogun.SetAgenda(input, scope)
	scope = Shogun.AgendaScope(scope)
	if not scope or not Shogun.CanAgenda(scope) then return false end
	-- Guild events use the existing dated week and its signup sheets, over guild chat alone.
	if scope == "guild" then return ns.Week and ns.Week.SetEntry(input, scope) or false end
	local minutes, title = Shogun.ParseAgenda(input)
	local W = ns.Week
	-- 1.1: a day and an hour, then what: an entry of the Shogun's week (Week.lua). After a number
	-- too ("30 Sat 20:00 Raid night", the 1.0 box's "30 " kept): the week's, never a 30-minute
	-- Agenda with its raid warning and popup for the whole army.
	if W and W.LooksLikeEntry and W.LooksLikeEntry(minutes and title or input) then
		local text = minutes and title or input
		if W.Parse(text) then return W.SetEntry(text, scope) end
		ns.Print(L.THRONE_AGENDA_USAGE)
		return false
	end
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
	local mine = { id = NewId(), title = title, at = now + minutes * 60, zone = Clean(ZoneName(), 40), by = ns.me, guild = GetGuildInfo("player"), mine = true, fired = {} }
	if Shogun.Preview() then
		agenda = mine
		ns.Print(L.THRONE_PREVIEW_NOTE)
		return Changed() or true
	end
	agenda = mine
	Shogun.SendAgenda()
	Warn(L.THRONE_AGENDA_SET:format(title, minutes, mine.zone), false, "agenda", { own = true })
	Changed()
	return true
end

function Shogun.SendAgenda()
	if not agenda or not agenda.mine or Shogun.Preview() then return end
	if not Shogun.AgendaAuthorized(ns.me, agenda.guild, false) then return end
	-- Seconds left, so a resend never moves the time (minutes rounded up did).
	local left = math.floor(agenda.at - ns.Now())
	if left < 30 then return end
	local a = agenda
	ns.Comm.Send("CHANNEL", ("T1~A~%d~%s~%d~%s~%s"):format(a.id, GetGuildInfo("player") or "", left, a.zone, a.title), "agenda",
		nil, nil, nil, { owner = Shogun, guard = function() return agenda == a and Shogun.AgendaAuthorized(ns.me, a.guild, false) end })
end

function Shogun.CancelAgenda()
	if not agenda then return end
	if Shogun.AgendaPreviewBlocked() then return false end
	if not Shogun.Preview() and not agenda.mine and not Shogun.CanAgenda("army") then return false end
	-- The Shogun or a Hand cancels it for everyone, whoever set it (its setter's client stops
	-- repeating it when the cancel reaches it).
	if not Shogun.Preview() then
		ns.Comm.Send("CHANNEL", ("T1~X~%d~%s"):format(agenda.id, GetGuildInfo("player") or ""), "agenda")
	end
	if ns.Week and ns.Week.Forget then ns.Week.Forget(agenda.id) end -- (1.1: a signup for it, and its nudge)
	agenda = nil
	Changed()
end

function Shogun.Agenda()
	if agenda and agenda.at < ns.Now() - 600 then agenda = nil end -- over for 10 minutes
	if agenda and not Shogun.Preview() and not Shogun.AgendaAuthorized(agenda.by, agenda.guild, false) then return nil end
	return agenda
end

local function OnAgenda(shogun, id, rest, guild)
	local seconds, zone, title = rest:match("^(%d+)~([^~]*)~(.*)$")
	seconds = tonumber(seconds)
	if not seconds or seconds < 30 or seconds > 720 * 60 or title == "" then return end
	local now = ns.Now()
	if agenda and agenda.id == id then
		if ns.FullName(agenda.by) ~= ns.FullName(shogun) then return end
		-- A resend: keep our time unless it is really off (late login, clock drift).
		if math.abs((now + seconds) - agenda.at) > 60 then agenda.at = now + seconds end
		return Changed()
	end
	agenda = { id = id, title = Clean(title, 60), at = now + seconds, zone = Clean(zone, 40), by = shogun, fired = {},
		guild = Shogun.CleanGuild(guild) } -- (1.1: its setter's guild, for the net-off: Week.lua)
	-- A new agenda is a raid warning and a popup (the appointment: what, when, where), but
	-- not more than once a minute whatever arrives.
	if now - lastAgendaWarn >= Shogun.AGENDA_GAP then
		lastAgendaWarn = now
		local a, byShogun = agenda, Shogun.FromShogun(shogun, guild)
		-- The popup says the minutes left when it shows (later, after an instance: 1.1).
		local function Popup()
			local minutes = math.max(1, math.ceil((a.at - ns.Now()) / 60))
			-- The Shogun by the army's name for him; a Hand by theirs (as OnSummon).
			local where = a.zone ~= "" and a.zone or "?"
			local text = byShogun and L.THRONE_AGENDA_POPUP:format(ns.ShogunName(shogun), a.title, minutes, where)
				or (Shogun.IsHandName(shogun) or Shogun.IsStewardName(shogun)) and L.THRONE_AGENDA_POPUP_HAND:format(ns.DisplayName(shogun), a.title, minutes, where)
				or L.HERALDRY_AGENDA_POPUP:format(ns.DisplayName(shogun), a.title, minutes, where)
			ns.ShowDialog("BANKAIGUILD_AGENDA_CALL", text)
		end
		Warn(L.THRONE_AGENDA_SET:format(a.title, math.ceil(seconds / 60), a.zone), false, "agenda", Shogun.AgendaHeld(a, Popup))
	end
	Changed()
end

-- The Agenda's raid warnings in an instance or on Busy (1.1, ns.Alert): one line for it and its
-- reminders, current until it is due (and while it is still the Agenda).
function Shogun.AgendaHeld(a, show)
	return { what = L.HELD_AGENDA:format(a.title), key = "agenda" .. tostring(a.id), show = show,
		open = function() return Shogun.Agenda() == a and a.at > ns.Now() end }
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

local shogunAt                 -- where the Shogun is, for everyone: { name, id, mapID, x, y, t }
local locationId = NewId()
local lastLocation = { t = -math.huge }
local Pins = ns.Pins()
local SHOW_FLAG = HBD_PINS_WORLDMAP_SHOW_CONTINENT or 2
local crowns                 -- { world, mini } pin frames, made on first use
local crownAt                -- where they are drawn now (drawn again only when he moved)

-- Configured opt-in: also used by the independent layer/match/lives policy. It must not be
-- rewritten merely because this frame has no publishable position (an instance or loading map).
function Shogun.SharingLocation() return ns.db ~= nil and ns.db.throneLocation == true end

local function LocationPosition()
	if IsInInstance and IsInInstance() then return nil, "instance" end
	local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
	if type(mapID) ~= "number" or mapID <= 0 or mapID >= math.huge or mapID ~= math.floor(mapID) then return nil, "position" end
	local pos = C_Map.GetPlayerMapPosition and C_Map.GetPlayerMapPosition(mapID, "player")
	if not pos or type(pos.GetXY) ~= "function" then return nil, "position" end
	local x, y = pos:GetXY()
	if type(x) ~= "number" or type(y) ~= "number" or x ~= x or y ~= y
		or x < 0 or x > 1 or y < 0 or y > 1 or (x == 0 and y == 0) then return nil, "position" end
	return mapID, x, y
end

-- Effective status uses exactly the sender's current position gate, not just its saved consent.
-- No role, consent or independent game-live setting is changed by asking this read-only status.
function Shogun.EffectiveLocation()
	if not Shogun.SharingLocation() then return false, "off" end
	if not Shogun.IsShogun() then return false, "role" end
	local mapID, why = LocationPosition()
	if not mapID then return false, why end
	return true
end

local function SendLocation(force)
	if not Shogun.SharingLocation() or not Shogun.IsShogun() then return end
	-- Quiet presence (Core.lua): his crown leaves no client; the army's copy expires on its own
	-- (LOCATION_EXPIRE), as after a logout. His layer and hello are held by Layers.lua and Comm.lua.
	if ns.QuietPresence and ns.QuietPresence() then return end
	local mapID, x, y = LocationPosition()
	if not mapID then return end
	local now = ns.Now()
	local moved = lastLocation.mapID ~= mapID or math.abs((lastLocation.x or 0) - x) > 0.003 or math.abs((lastLocation.y or 0) - y) > 0.003
	if not force and (now - lastLocation.t < Shogun.LOCATION_EVERY or (not moved and now - lastLocation.t < Shogun.LOCATION_STILL)) then return end
	lastLocation = { mapID = mapID, x = x, y = y, t = now }
	ns.Comm.Send("CHANNEL", ("T1~P~%d~%s~%d~%d~%d"):format(locationId, GetGuildInfo("player") or "", mapID,
		math.floor(x * 1000 + 0.5), math.floor(y * 1000 + 0.5)), "shogunlocation")
end

-- Quiet presence turned off (Core.lua): his crown at once again, while he shares it.
ns.On("QUIET_PRESENCE_CHANGED", function(on) if on == false then SendLocation(true) end end)

-- privateTransition is used only while Core is entering quiet presence. The crown and layer
-- withdrawals still leave, but the ordinary final hello, donation refresh and public events wait
-- until quiet presence is active, so hiding never renews an online lease on the way out.
function Shogun.ToggleLocation(privateTransition)
	if Shogun.Preview() then return ns.Print(L.THRONE_PREVIEW_NOTE) end
	if not Shogun.IsShogun() then return end
	ns.db.throneLocation = not Shogun.SharingLocation()
	if Shogun.SharingLocation() then
		-- Each explicit on period is a new lease. A sighting from before an opt-out must not
		-- become usable again if the crown is shown moments later.
		locationId = locationId % 99999 + 1
		ns.Print(L.THRONE_LOCATION_SHOWN)
		-- His crown is his yes for his layer too (Layers.lua): the army asks to join him there.
		-- Both go out now (1.0.0: his layer waited for its next announcement, up to ten minutes).
		ns.Print(L.THRONE_LOCATION_LAYER)
		SendLocation(true)
		ns.Layers.AnnounceNow()
	else
		ns.Print(L.THRONE_LOCATION_HIDDEN)
		lastLocation = { t = -math.huge }
		-- (Quiet presence, Core.lua: no removal either; the army's copy expires on its own.)
		if not (ns.QuietPresence and ns.QuietPresence()) then
			ns.Comm.Send("CHANNEL", ("T1~Q~%d~%s"):format(locationId, GetGuildInfo("player") or ""), "shogunlocation")
		end
		-- His layer goes with it, at once, and his hello stops naming his zone (Layers.Sharing).
		ns.Layers.Withdraw()
		if privateTransition ~= true then ns.Comm.Hello(true) end
	end
	if privateTransition ~= true then
		ns.Fire("SHOGUN_LOCATION_CHANGED", Shogun.SharingLocation() and "show" or "hide", ns.FullName(ns.me), locationId)
	end
	-- Taking donations (1.1): his zone in it follows his crown at once.
	if privateTransition ~= true and ns.Treasury and ns.Treasury.DonationsMoved then ns.Treasury.DonationsMoved() end
	Changed()
	return true, locationId
end

local function CrownTip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(L.THRONE_LOCATION_PIN:format(shogunAt and shogunAt.name or "?"), 1, 0.82, 0)
	GameTooltip:Show()
end
local function Crown(size)
	local f = CreateFrame("Frame", nil, UIParent)
	f.bankaiguild = true -- (ours: photo mode leaves it shown, UI.TogglePhoto)
	f:SetSize(size, size)
	f.icon = f:CreateTexture(nil, "OVERLAY")
	f.icon:SetTexture(ns.CROWN_ICON)
	f.icon:SetAllPoints()
	f:EnableMouse(true)
	f:SetScript("OnEnter", CrownTip)
	f:SetScript("OnLeave", function() GameTooltip:Hide() end)
	return f
end
-- The world map's crown sits beside the zone circles, never over their numbers (1.0.0,
-- Map.Badge); the minimap's is a plain crown (no circles there).
local function WorldCrown()
	local f = ns.Map.Badge(20, false)
	ns.Map.SetBadge(f, ns.CROWN_ICON)
	f.badge:SetScript("OnEnter", CrownTip)
	f.badge:SetScript("OnLeave", function() GameTooltip:Hide() end)
	return f
end

-- Draws (or removes) the crown on the world map and the minimap. The world map's only with
-- mouse and keyboard (ns.WorldMapIcons); drawn again when that changes, even where he stands still.
-- 1.1.6: never for a sanctioned player (WatchChat.Barred "locations", as Shogun.Location): one drawn
-- before is taken off (every LOCATION_EVERY and at once on WATCHCHAT_CHANGED), and drawn again
-- once the sanction ends while the Shogun still shares his position.
function Shogun.RefreshCrown()
	if not Pins then return end
	local world = ns.WorldMapIcons(Pins, Shogun) -- gp:worldmap-icons
	if shogunAt and ns.Now() - shogunAt.t > Shogun.LOCATION_EXPIRE then shogunAt = nil end
	local WC = ns.WatchChat
	local barred = WC and not WC.missing and WC.Barred and WC.Barred("locations")
	if not shogunAt or barred then
		if crowns and crownAt then
			if world then Pins:RemoveWorldMapIcon(Shogun, crowns.world) end
			Pins:RemoveMinimapIcon(Shogun, crowns.mini)
			crowns.world:Hide()
			crowns.mini:Hide()
		end
		crownAt = nil
		return
	end
	if crownAt and crownAt.mapID == shogunAt.mapID and crownAt.x == shogunAt.x and crownAt.y == shogunAt.y and crownAt.world == world then return end
	crowns = crowns or { world = WorldCrown(), mini = Crown(16) }
	-- Taken off before it is put back: the map library makes a new map pin on every add.
	if crownAt then
		if world then Pins:RemoveWorldMapIcon(Shogun, crowns.world) end
		Pins:RemoveMinimapIcon(Shogun, crowns.mini)
	end
	crownAt = { mapID = shogunAt.mapID, x = shogunAt.x, y = shogunAt.y, world = world }
	if world then Pins:AddWorldMapIconMap(Shogun, crowns.world, shogunAt.mapID, shogunAt.x, shogunAt.y, SHOW_FLAG) end
	Pins:AddMinimapIconMap(Shogun, crowns.mini, shogunAt.mapID, shogunAt.x, shogunAt.y, true, true) -- gp:minimap
end

local function OnLocation(shogun, id, rest)
	local mapID, x, y = rest:match("^(%d+)~(%d+)~(%d+)$")
	mapID, x, y = tonumber(mapID), tonumber(x), tonumber(y)
	if not mapID or x > 1000 or y > 1000 then return end
	shogunAt = { from = ns.FullName(shogun), name = ns.ShogunName(shogun), id = id, mapID = mapID, x = x / 1000, y = y / 1000, t = ns.Now() }
	ns.SafeCall("shogun crown", Shogun.RefreshCrown)
	ns.Fire("SHOGUN_LOCATION_CHANGED", "show", shogunAt.from, shogunAt.id)
	Changed()
end

-- Where the Shogun is, while he shares it: { name, id, mapID, x, y, t } or nil.
function Shogun.Location()
	if shogunAt and ns.Now() - shogunAt.t > Shogun.LOCATION_EXPIRE then return nil end
	-- 1.1.6: a sanctioned player (WatchChat.Barred "locations") sees neither the Shogun's crown nor
	-- his arrow, and asks for no layer of his, while it lasts.
	local WC = ns.WatchChat
	if shogunAt and WC and not WC.missing and WC.Barred and WC.Barred("locations") then return nil end
	return shogunAt
end

function Shogun.HandleCommand(dist, sender, text)
	if dist ~= "CHANNEL" and dist ~= "GUILD" then return end
	local kind, id, guild, rest = text:match("^T1~(%a)~(%d+)~([^~]*)~?(.*)$")
	if not kind then return end
	local guildOnly = dist == "GUILD"
	local agendaKind = kind == "A" or kind == "D" or kind == "R" or kind == "X"
	if guildOnly and kind ~= "D" and kind ~= "R" then return end
	local ownCancel = kind == "D" and rest:find("^0~") and ns.Week and ns.Week.OwnCancel and ns.Week.OwnCancel(sender, tonumber(id), guild, guildOnly)
		or kind == "X" and agenda and agenda.id == tonumber(id) and agenda.by == ns.FullName(sender)
	local authorized = ownCancel or agendaKind and Shogun.AgendaAuthorized(sender, guild, guildOnly) or (not agendaKind and Shogun.Authorized(kind, sender, guild))
	if not authorized then
		-- Positions come every few seconds: not logged.
		if kind ~= "P" then
			ns.Log("throne %s from %s ignored: not the Shogun of %s nor his Hand%s", kind, sender, tostring(guild),
				ns.ShogunCharacter() and "" or " (no Shogun named on this side: nobody commands)")
		end
		return
	end
	id = tonumber(id)
	-- 1.1: a Hand (or a Steward) the moderators took off (net-off, Moderation.lua): none of their
	-- calls to the army shows. (Never the Shogun: nobody takes him off.)
	-- But a setter taking his own entry off the Shogun's week (a D of 0 seconds): Week.lua takes it
	-- for his own entry alone (1.1 review: held, it showed again everywhere once he was back).
	if Shogun.HIDDEN_CALLS[kind] and ns.Moderation.Hides and ns.Moderation.Hides(sender, guild) and not (kind == "D" and rest:find("^0~")) then
		return ns.Log("throne %s from %s ignored: net-off", kind, sender)
	end
	-- 1.1.6: a Hand or a Steward under a moderator's timeout or hold (WatchChat.Barred "powers")
	-- calls nobody while it lasts. (Never the Shogun: nobody times him out.)
	local WC = ns.WatchChat
	if Shogun.HIDDEN_CALLS[kind] and WC and not WC.missing and WC.Barred and not (kind == "D" and rest:find("^0~"))
		and not ShogunSender(sender, guild) and WC.Barred("powers", sender) then
		return ns.Log("throne %s from %s ignored: sanctioned", kind, sender)
	end
	-- The Shogun's own client takes his Hands' news (the agenda, the gates, a cancel), not
	-- their calls to the army: no roll call popup, patrol or poll window for him.
	if Shogun.IsShogun() and (kind == "S" or kind == "I" or kind == "V") and not ShogunSender(sender, guild) then return end
	if kind == "S" then OnSummon(sender, id, guild)
	elseif kind == "H" then OnHands(sender, rest)
	elseif kind == "N" then OnStewardHands(sender, rest)
	elseif kinds[kind] then kinds[kind](sender, id, rest, guild, guildOnly)
	-- (11-02: no Royal Inspection or untabarded list any more: "I" and "U" from older clients are dropped.)
	elseif kind == "A" then OnAgenda(sender, id, rest, guild)
	elseif kind == "P" then OnLocation(sender, id, rest)
	elseif kind == "Q" then
		-- Only whoever put the crown there takes it off.
		if shogunAt and (shogunAt.from ~= ns.FullName(sender) or shogunAt.id ~= id) then
			-- The Q must not hide a newer crown, but its own old lease is still explicitly revoked.
			ns.Fire("SHOGUN_LOCATION_CHANGED", "revoke", ns.FullName(sender), id)
			return
		end
		shogunAt = nil
		ns.SafeCall("shogun crown", Shogun.RefreshCrown)
		ns.Fire("SHOGUN_LOCATION_CHANGED", "hide", ns.FullName(sender), id)
		Changed()
	elseif kind == "X" then
		if agenda and agenda.id == id then
			agenda = nil
			Changed()
		end
		-- 1.1: our signup for it goes, and its nudge (held after a /reload too: Week.lua).
		if ns.Week and ns.Week.Forget then ns.Week.Forget(id) end
	end
end
ns.Comm.Handle("T1", function(...) Shogun.HandleCommand(...) end)

-- 1.1.6: a sanction given or lifted (WatchChat.lua): the crown taken off or drawn again at once.
ns.On("WATCHCHAT_CHANGED", function() ns.SafeCall("shogun crown", Shogun.RefreshCrown) end)

ns.On("LOGIN", function()
	-- The Shogun's position, while he shares it; everyone's crown expires on its own.
	-- (1.2.3, the Shogun's stream: his crown already on from the last session, the army could not ask
	-- for his layer until he hid and showed it again.) His layer goes out at his first tick as the
	-- Shogun, as Show me on the map sends it: at login the creature read that announces it
	-- (Layers.Observe) can come before the game names his guild, when he is not the Shogun yet here,
	-- and the minute's announcement (Layers.Tick) starts a minute or two after login.
	ns.Every(Shogun.LOCATION_EVERY, "shogun location", function()
		SendLocation()
		local Ly = ns.Layers
		if Shogun.SharingLocation() and Shogun.IsShogun() and not (IsInInstance and IsInInstance())
			and Ly and Ly.SentAt and Ly.AnnounceNow and Ly.SentAt() == nil then Ly.AnnounceNow() end
		Shogun.RefreshCrown()
	end)
	-- His Hands from the last session; he repeats them for late logins (HANDS_EVERY). A
	-- Steward's own list the same, from his client (1.0.0).
	Shogun.LoadHands()
	ns.Every(60, "shogun hands", function()
		Shogun.SendHands()
		Shogun.SendStewardHands()
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
				Warn(L.THRONE_AGENDA_SOON:format(a.title, math.max(1, math.ceil(left / 60)), a.zone), false, "agenda", Shogun.AgendaHeld(a))
			end
		end
		if a.mine and not QuietRepeat(false) and (not a.sentAt or ns.Now() - a.sentAt >= Shogun.AGENDA_RESEND) then
			a.sentAt = ns.Now()
			Shogun.SendAgenda()
		end
		Changed()
	end)
end)

StaticPopupDialogs["BANKAIGUILD_SHOGUN_AGENDA"] = {
	text = "%s",
	button1 = OKAY or "OK",
	button2 = CANCEL or "Cancel",
	hasEditBox = true,
	editBoxWidth = 260,
	maxLetters = 70,
	OnShow = function(self)
		-- Empty (1.1): the box takes minutes or a day and an hour, and a "30 " put there first
		-- would turn a week entry into a 30-minute Agenda.
		local eb = self.editBox or self.EditBox
		if eb then eb:SetText(""); eb:SetFocus() end
	end,
	OnAccept = function(self, data)
		local eb = self.editBox or self.EditBox
		data = data or self.data
		ns.SafeCall("agenda", Shogun.SetAgenda, eb and eb:GetText(), type(data) == "table" and data.scope or nil)
	end,
	EditBoxOnEnterPressed = function(self)
		local data = self:GetParent().data
		ns.SafeCall("agenda", Shogun.SetAgenda, self:GetText(), type(data) == "table" and data.scope or nil)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

function Shogun.AgendaPrompt(scope)
	scope = Shogun.AgendaScope(scope)
	if not scope or not Shogun.CanAgenda(scope) then return false end
	ns.ShowDialog("BANKAIGUILD_SHOGUN_AGENDA", scope == "guild" and L.WEEK_GUILD_PROMPT or L.THRONE_AGENDA_PROMPT, nil, { scope = scope })
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

---------------------------------------------------------------------------
-- Where the Shogun's calls show: the roll call in the Realm tab (next to the Elders it calls),
-- the Royal Inspection in The Watch's Tabards. Plain rows (not the parchment), for the Shogun and
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
			-- (1.1.2's review: Silent and the unconfirmed say why they can be off, the answer bank's.)
			local function Why(tt) if ns.Answers and ns.Answers.WhyTip then ns.Answers.WhyTip(tt, "count-throne-silent") end end
			for _, group in ipairs({ { L.THRONE_PRESENT_N, present, Green }, { L.THRONE_BUSY_N, busy, Grey }, { L.THRONE_SILENT_N, silent, Grey } }) do
				local label = group[1]:format(#group[2])
				lines[#lines + 1] = { indent = 1, text = group[3](label), tooltip = group[2] == silent and function(tt)
					tt:AddLine(label, 1, 0.82, 0)
					Why(tt)
				end or nil }
				for _, row in ipairs(group[2]) do lines[#lines + 1] = { indent = 2, text = row } end
			end
			if others > 0 then
				local label = L.THRONE_UNCONFIRMED:format(others)
				lines[#lines + 1] = { indent = 1, text = Grey(label), tooltip = function(tt)
					tt:AddLine(label, 1, 0.82, 0)
					Why(tt)
				end }
			end
		end
		lines[#lines + 1] = { indent = 1, text = Gold("> " .. L.ROLL_AGAIN), onClick = function() Shogun.Summon() end }
	end
	lines[#lines].gapAfter = true
	return lines
end

-- The Royal Inspection on top of The Watch's Tabards: call one, then what the patrols reported.
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
		-- (1.2.4: as many inspected, the higher average level first, then the name: one order every time;
		-- 1.2.4's review: its average level after its count, so that order is seen, both kept whole up
		-- to half the row.)
		local guilds = {}
		for guild, g in pairs(byGuild) do guilds[#guilds + 1] = { name = guild, ok = g.ok, n = g.ok + g.bad } end
		ns.Data.SortGuildCounts(guilds, "n")
		local Tag = ns.Views and ns.Views.AvgTag or function() return "" end
		for _, g in ipairs(guilds) do
			lines[#lines + 1] = { indent = 2, text = Green("<" .. g.name .. ">"), rightWide = true,
				right = ("%d%%  (%d/%d)"):format(g.n > 0 and math.floor(g.ok * 100 / g.n + 0.5) or 0, g.ok, g.n) .. Tag(ns.Data.Guild(g.name)) }
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
	local steward = Shogun.IsSteward()
	local lines = Para({ Line(L.HANDS_TITLE, TITLE) }, steward and L.HANDS_HINT_STEWARD or L.HANDS_HINT, INK, { gapAfter = true })
	if Shogun.SetsLists() or Shogun.Preview() then
		local list = Shogun.Hands()
		lines[#lines + 1] = Line("+ " .. L.HANDS_ADD, TITLE, { onClick = function() ns.ShowDialog("BANKAIGUILD_SHOGUN_HAND") end })
		for _, name in ipairs(list) do
			lines[#lines + 1] = Line(ns.DisplayName(name), INK, { indent = 1, key = name,
				onClick = function() ns.ShowDialog("BANKAIGUILD_SHOGUN_UNHAND", ns.DisplayName(name), nil, name) end,
				tooltip = function(tt) tt:AddLine(ns.DisplayName(name), 1, 0.82, 0); tt:AddLine(L.HANDS_CLICK_REMOVE, 1, 1, 1, true) end })
		end
		if #list == 0 then lines[#lines + 1] = Line(L.HANDS_NONE, INK, { indent = 1 }) end
		lines[#lines].gapAfter = true
		-- The Hands the others named (1.0.0: the Shogun, each Steward), under who named them: theirs
		-- to remove, lines to read here (no button).
		for _, o in ipairs(Shogun.OthersHands()) do
			lines[#lines + 1] = Line(o.steward and L.HANDS_NAMED_BY_STEWARD:format(StewardLabel(o.steward)) or L.HANDS_NAMED_BY_SHOGUN, TITLE)
			for _, name in ipairs(o.names) do lines[#lines + 1] = Line(ns.DisplayName(name), INK, { indent = 1 }) end
			lines[#lines].gapAfter = true
		end
		Para(lines, steward and L.HANDS_NOTE_STEWARD or L.HANDS_NOTE, INK)
	end
	return lines
end

Shogun.Line, Shogun.INK, Shogun.TITLE = Line, INK, TITLE

local function Go(mode) return function() Shogun.Show(mode) end end

-- The Throne Room: what is the Shogun's alone. Each tool lives where it belongs (the agenda here,
-- Judgment and the court in The Watch (1.2), the Hands and his crown on the map on the buttons
-- beside, the roll call in the Realm, the inspection in the Tabards, Poll and the treasury
-- on their own tabs): here, the army's key. A Hand's: where their tools are. His Steward's
-- (1.0.0): the Shogun's, with what is his to do in the Shogun's name (he holds no court). 1.1.5 (the
-- author's calls): no treasury here any more (its own tab has it all), and under it all, the
-- Shogun's centurions (1.2.4, the author's rule: the High Council, to read, nobody named there:
-- Nominees.MainLines); a High Councillor who is none of them has the Throne for that alone. One who
-- also leads another Bankai Guild guild has his Guild tab's section after it.
local function HomeLines()
	local mine = Shogun.IsShogun() or Shogun.Preview()
	local steward = not mine and Shogun.IsSteward()
	local hand = not mine and not steward and Shogun.IsHand()
	local title = (mine or steward) and L.THRONE_ROOM
		or hand and L.THRONE_ROOM_HAND:format(ns.ShogunName(handsShogun or ns.ShogunCharacter())) or L.THRONE_ROOM_COUNCIL
	local lines = { Line(title, TITLE, { gapAfter = true }) }
	if steward then
		Para(lines, L.THRONE_STEWARD_HINT, INK, { gapAfter = true })
	elseif hand then
		Para(lines, L.THRONE_HAND_HINT, INK, { gapAfter = true })
	elseif not mine then
		Para(lines, L.THRONE_COUNCIL_HINT, INK, { gapAfter = true })
	end
	-- (1.2: the court's queue is in The Watch, with Judgment.)
	-- 1.3.4: and the addon's author's, in his own view (Keys.AuthorHere), neither Shogun nor Steward.
	if mine or steward or (ns.Keys.AuthorHere and ns.Keys.AuthorHere()) then
		-- 1.1: the army's key, the Shogun's to rotate, or his Steward's for him (Keys.lua).
		for _, l in ipairs(ns.Keys.ThroneLines and ns.Keys.ThroneLines() or {}) do lines[#lines + 1] = l end
	end
	if #lines > 1 then lines[#lines].gapAfter = true end
	local N = ns.Nominees
	if N and not N.missing and N.MainLines then
		N.MainLines(lines)
		if Shogun.GuildShown() then
			lines[#lines].gapAfter = true
			N.PageLines(lines)
		end
	end
	return lines
end

-- The Shogun's own pages (and his Steward's): a Hand's Throne Room has no link to them.
Shogun.SHOGUN_PAGES = { hands = true }

-- For Views.Build("throne"): lines, detail title, detail text.
-- The Throne opens on the Throne Room (the Shogun's administration; a Hand's: where their tools
-- are). Judgment and the court's queue are in The Watch. (1.0.0: no
-- letter before it any more.) His Steward's says on top, on every page, that he acts for the Shogun.
function Shogun.Build(s)
	-- 1.1.5: a guild master's Guild tab, in the Throne's place (Nominees.lua). (1.2: the author sees
	-- every tab in his own view, ViewAs.lua: without a role of his own here, the Throne as it is.)
	local V = ns.ViewAs
	-- (1.3.4: the author himself leading a guild too sees the Throne in his own view, its key's
	-- rotation his; his Guild tab's section follows the Throne Room there, as a Shogun's does.)
	local authorsOwn = type(V) == "table" and not V.missing and type(V.Available) == "function" and V.Available() == true
		and V.Role() == "my" and (not Shogun.GuildShown() or (ns.Keys and ns.Keys.AuthorHere and ns.Keys.AuthorHere() == true))
	if not Shogun.ThroneShown() and not authorsOwn then
		local N = ns.Nominees
		local master, guild = Shogun.GuildShown(), N and N.GuildAccess and select(2, N.GuildAccess())
		local detail = N and N.IsMaster and N.IsMaster() and L.GUILD_TAB_DETAIL or L.GUILD_DEPARTMENT_SCOPE
		local lines = master and N.GuildLines() or {}
		-- (1.4.0) His letter from the Shogun and its checklist, reopened from here (RoleBriefings.lua).
		local RB = ns.RoleBriefings
		if master and type(RB) == "table" and not RB.missing and type(RB.GuildTabLine) == "function" then RB.GuildTabLine(lines) end
		return lines, L.TAB_GUILD, master and detail:format(tostring(guild)) or nil
	end
	local lines, home
	if not Shogun.mode then Shogun.mode = "home" end
	local mode = Shogun.mode
	if Shogun.SHOGUN_PAGES[mode] and not (Shogun.SetsLists() or Shogun.Preview()) then mode = "home" end
	if mode == "hands" then lines = HandsLines()
	else lines, home = HomeLines(), true end
	-- Every other page leads back to the Throne Room.
	if not home then table.insert(lines, 1, Line("< " .. L.THRONE_ROOM, INK, { onClick = Go("home"), gapAfter = true })) end
	-- While the army sees him on the map, the page says so on top, whatever it shows.
	if Shogun.SharingLocation() and Shogun.IsShogun() then
		local status = Shogun.EffectiveLocation() and L.THRONE_LOCATION_LIVE or L.THRONE_LOCATION_PAUSED
		table.insert(lines, 1, Line("|T" .. ns.CROWN_ICON .. ":0|t " .. status, TITLE, { gapAfter = true }))
	end
	local steward = Shogun.IsSteward()
	if steward then table.insert(lines, 1, Line("|T" .. ns.CROWN_ICON .. ":0|t " .. L.STEWARD_ACTING, TITLE, { gapAfter = true })) end
	-- (1.2: the author sees every tab, the Throne too, without a role here: ViewAs.lua.)
	local detail = steward and L.THRONE_YOU_ARE_STEWARD:format(ns.ShogunName(ns.ShogunCharacter()))
		or Shogun.IsHand() and L.THRONE_YOU_ARE_HAND:format(ns.ShogunName(handsShogun or ns.ShogunCharacter()))
		or (Shogun.IsShogun() or Shogun.Preview()) and L.THRONE_YOU_ARE_SHOGUN
		or (ns.IsHighCouncillor(ns.me) == true or ns.ViewAs and ns.ViewAs.Is and ns.ViewAs.Is("councillor")) and L.THRONE_YOU_ARE_COUNCILLOR
		or L.THRONE_NOT_YOURS
	return lines, L.TAB_THRONE, detail
end

function Shogun.Show(mode)
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

-- /bk status (1.0.0): the Shogun's Steward as this client knows him (the signed titles list), and
-- the lists of Hands it holds, each its owner's: how many, and whether it still lasts here.
function Shogun.StewardStatusLine()
	local who
	if Shogun.IsSteward() then
		who = "you, acting for the Shogun"
	elseif not ns.ShogunCharacter() then
		who = "none (no Shogun named on this side)"
	elseif not ns.CouncilTitles() then
		who = "none known (no signed titles list here yet)"
	else
		local shown = {}
		for i, n in ipairs(ns.Stewards()) do shown[i] = StewardLabel(n) end
		who = #shown > 0 and table.concat(shown, ", ") or "none named"
	end
	-- (1.2.4: a list stands until its owner's newer one, whenever it was heard)
	local function Heard(at) return "heard " .. ns.Ago(at) end
	local held = {}
	if Shogun.IsShogun() then held[1] = ("the Shogun's %d (yours)"):format(#myHands)
	elseif handsAt ~= -math.huge and HeardShogun() then held[1] = ("the Shogun's %d (%s)"):format(#handsOrder, Heard(handsAt)) end
	if Shogun.IsSteward() then held[#held + 1] = ("yours %d"):format(#myStewardHands) end
	local stewards = {}
	for steward in pairs(stewardHands) do stewards[#stewards + 1] = steward end
	table.sort(stewards)
	for _, steward in ipairs(stewards) do
		local s = stewardHands[steward]
		local state = Shogun.IsStewardName(steward) and Heard(s.at) or "ended: no longer a Steward"
		held[#held + 1] = ("%s's %d (%s)"):format(StewardLabel(steward), #s.names, state)
	end
	return ("%s  |  Hands: %s"):format(who, #held > 0 and table.concat(held, ", ") or "none")
end

-- The author's Workshop: Shobek's view on or off (the Throne, Poll, the Shogun's calls in
-- the Realm and the Tabards), to see and try them. Nothing the view does reaches anyone.
function Shogun.SetDevView(on)
	ns.db.devShogunView = on and true or false
	-- The preview's treasury switches and keepers were its own: gone with it. (1.2.4: it names no
	-- centurions any more; 1.1.5's copy of the ones it named goes at the next minute, Nominees.Minute.)
	if not on then ns.db.previewTreasuryFlags, ns.db.previewTreasuryKeepers = nil, nil end
	ns.Print(on and L.DEV_SHOGUN_VIEW_NOW_ON or L.DEV_SHOGUN_VIEW_NOW_OFF)
	ns.Fire("DATA_CHANGED")
	Changed()
end
function Shogun.Reset()
	summon, inspect, agenda, inspecting, shogunAt, crownAt = nil, nil, nil, nil, nil, nil
	hands, handsOrder, handsAt, lastHandsSent, handsShogun, handsSendPending = {}, {}, -math.huge, -math.huge, nil, false
	wipe(myHands)
	wipe(stewardHands); wipe(myStewardHands)
	lastStewardSent = -math.huge
	lastLocation = { t = -math.huge }
	lastSummonSeen, lastInspectSeen, lastSummonSent, lastInspectSent = -math.huge, -math.huge, -math.huge, -math.huge
	lastUntabardedSent = -math.huge
	lastAgendaSent, lastAgendaWarn, changePending = -math.huge, -math.huge, false
	Shogun.mode, rollOpen = nil, false
end
