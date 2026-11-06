local ADDON, ns = ...
local L = ns.L

-- The honor boards (11-02), on The Way page (ChurchView.lua): the guild charter's Jin (Generosity)
-- and "Share the road", as kudos, and its "Honor in combat", as the /bow that follows a kill.
-- - Kudos: /bk thanks <Name> or the right-click line thanks a member for his help. Each giver
--   thanks one player once a day, KUDOS_PER_DAY players a day at most, never himself.
-- - Bows: our own /bow within BOW_WINDOW seconds of our killing blow on a player (Bow.killAt)
--   counts once, BOW_GAP apart, BOWS_PER_WEEK a week at most.
-- Both go out on the Bankai Guild channel as HB, one short line each; every client keeps the week's
-- tallies it heard (ns.rdb.honor), so a player offline when one went out does not count it: the
-- boards are this client's, as the page says. A new week (server time) starts them again.
--   HB~K~<Name-Realm>   the sender thanks that player
--   HB~B~               the sender bowed after his kill
local Honor = {}
ns.Honor = Honor

Honor.KUDOS_PER_DAY = 5
Honor.BOW_WINDOW = 60
Honor.BOW_GAP = 30
Honor.BOWS_PER_WEEK = 20
Honor.TOP = 5
Honor.WEEK = 7 * 86400
Honor.now = function() return (GetServerTime and GetServerTime()) or time() end -- (tests)

local function Key(name) return ns.Fold(tostring(name or "")) end
local function Week(t) return math.floor(t / Honor.WEEK) end
local function Day(t) return math.floor(t / 86400) end

-- This week's book, started again when the week changed.
function Honor.Book()
	local r = ns.rdb
	if type(r) ~= "table" then return nil end
	local week = Week(Honor.now())
	local h = r.honor
	if type(h) ~= "table" or h.week ~= week then
		h = { week = week, kudos = {}, gave = {}, given = {}, bows = {}, bowAt = {} }
		r.honor = h
	end
	return h
end

local function Valid(name)
	return type(name) == "string" and #name <= 48 and name:find("^[^%s~|:;]+%-[^%s~|:;]+$") ~= nil
end

-- One kudo from giver to target, if the rules let it: true when it counted.
function Honor.AddKudo(giver, target)
	local h = Honor.Book()
	if not h or not Valid(giver) or not Valid(target) then return false end
	local g, t = Key(giver), Key(target)
	if g == t then return false end
	local day = Day(Honor.now())
	local pair = g .. ">" .. t
	if h.gave[pair] == day then return false end
	local count = h.given[g]
	if type(count) ~= "table" or count.day ~= day then count = { day = day, n = 0 } end
	if count.n >= Honor.KUDOS_PER_DAY then return false end
	count.n = count.n + 1
	h.given[g], h.gave[pair] = count, day
	local e = h.kudos[t] or { name = target, n = 0 }
	e.n = e.n + 1
	h.kudos[t] = e
	ns.Fire("HONOR_CHANGED")
	return true
end

-- One bow of `who`, at most one each BOW_GAP and BOWS_PER_WEEK a week: true when it counted.
function Honor.AddBow(who)
	local h = Honor.Book()
	if not h or not Valid(who) then return false end
	local k, now = Key(who), Honor.now()
	if now - (h.bowAt[k] or -math.huge) < Honor.BOW_GAP then return false end
	local e = h.bows[k] or { name = who, n = 0 }
	if e.n >= Honor.BOWS_PER_WEEK then return false end
	e.n, h.bowAt[k] = e.n + 1, now
	h.bows[k] = e
	ns.Fire("HONOR_CHANGED")
	return true
end

-- /bk thanks <Name>: kept here at once, then told to the army.
function Honor.Thank(name)
	name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" then return ns.Print(L.KUDOS_USAGE) end
	if not ns.IsMember() then return ns.Print(ns.MembersOnlyText and ns.MembersOnlyText() or L.KUDOS_USAGE) end
	local target = ns.FullName(name:sub(1, 1):upper() .. name:sub(2))
	if not Valid(target) then return ns.Print(L.KUDOS_USAGE) end
	if Key(target) == Key(ns.me) then return ns.Print(L.KUDOS_SELF) end
	if not Honor.AddKudo(ns.me, target) then return ns.Print(L.KUDOS_LIMIT:format(Honor.KUDOS_PER_DAY)) end
	ns.Comm.Send("CHANNEL", "HB~K~" .. target, "honor kudo " .. Key(target))
	ns.Print(L.KUDOS_SENT:format(ns.DisplayName(target)))
	return true
end

-- Our own emote (the game's DoEmote, which /bow calls, by its token in every client language): a
-- BOW within BOW_WINDOW of our killing blow on a player counts.
function Honor.OnEmote(token)
	if type(token) ~= "string" or (issecretvalue and issecretvalue(token)) or token:upper() ~= "BOW" then return false end
	local Bow = ns.Bow
	if not Bow or GetTime() - (Bow.killAt or -math.huge) > Honor.BOW_WINDOW then return false end
	if not Honor.AddBow(ns.me) then return false end
	Bow.killAt = -math.huge -- (one bow a kill)
	ns.Comm.Send("CHANNEL", "HB~B~", "honor bow")
	ns.Print(L.BOW_COUNTED)
	return true
end

function Honor.Handle(dist, sender, text)
	if dist ~= "CHANNEL" or type(text) ~= "string" or #text > 80 or not Valid(ns.FullName(sender)) then return false end
	local kind, rest = text:match("^HB~(%u)~(.*)$")
	if kind == "K" then return Honor.AddKudo(ns.FullName(sender), rest) end
	if kind == "B" and rest == "" then return Honor.AddBow(ns.FullName(sender)) end
	return false
end
ns.Comm.Handle("HB", function(...) return Honor.Handle(...) end)

-- The week's top of a tally, most first, then by name.
function Honor.Top(which, n)
	local h = Honor.Book()
	local out = {}
	for _, e in pairs(h and h[which] or {}) do out[#out + 1] = e end
	table.sort(out, function(a, b) if a.n ~= b.n then return a.n > b.n end return a.name < b.name end)
	for i = #out, (n or Honor.TOP) + 1, -1 do out[i] = nil end
	return out
end

-- The boards of the Realm's Rankings page (11-05: the Way's before).
function Honor.Lines(lines, Gold, Grey)
	local function Board(title, which, empty)
		lines[#lines + 1] = { header = true, text = title,
			tooltip = function(tt) tt:AddLine(title, 1, 0.82, 0); tt:AddLine(L.HONOR_BOARD_TIP, 1, 1, 1, true) end }
		local top = Honor.Top(which)
		for i, e in ipairs(top) do
			lines[#lines + 1] = { indent = 1, text = ("%d.  %s"):format(i, ns.DisplayName(e.name)), right = Gold(tostring(e.n)) }
		end
		if #top == 0 then lines[#lines + 1] = { indent = 1, text = Grey(empty) } end
		lines[#lines].gapAfter = true
	end
	Board(L.KUDOS_TITLE, "kudos", L.KUDOS_EMPTY)
	Board(L.BOWS_TITLE, "bows", L.BOWS_EMPTY)
	lines[#lines + 1] = { indent = 1, text = Grey(L.KUDOS_HOW) }
end

-- The Realm's Rankings page: its link, and the boards under a way back.
ns.RealmPages = ns.RealmPages or {}
table.insert(ns.RealmPages, { key = "rankings", tip = "REALM",
	Link = function()
		if ns.IsMember() then return { text = "|cffffd200> " .. L.RANKINGS_TITLE .. "|r", onClick = function() ns.Views.ShowPage("rankings") end } end
	end,
	Lines = function()
		local function Gold(s) return "|cffffd200" .. s .. "|r" end
		local function Grey(s) return "|cff999999" .. s .. "|r" end
		local lines = { { text = Gold(L.CHATS_BACK), onClick = function() ns.Views.ShowPage(nil) end, gapAfter = true },
			{ header = true, text = L.RANKINGS_TITLE, gapAfter = true } }
		Honor.Lines(lines, Gold, Grey)
		return lines
	end })

-- (A post-hook: the emote is the game's own, read after it ran; GamepadRegistry.lua's "emote-hook".)
if hooksecurefunc and DoEmote then -- gp:emote-hook
	hooksecurefunc("DoEmote", function(token) ns.SafeCall("honor bow", Honor.OnEmote, token) end) -- gp:emote-hook
end

-- The right-click line on a member: thank him.
if ns.PlayerMenu and ns.PlayerMenu.Add then
	ns.PlayerMenu.Add("kudos", function(target, menu)
		if not (target and target.name) or Key(ns.FullName(target.name)) == Key(ns.me) then return end
		local name = target.name
		menu.Button(L.KUDOS_MENU, function() Honor.Thank(name) end, L.KUDOS_TITLE, L.KUDOS_MENU_TIP, not target.locked)
	end, 45, { bankaiguild = true })
end
