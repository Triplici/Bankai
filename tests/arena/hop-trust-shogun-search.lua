-- 1.2.1: the Shogun's match search lists only the names the addon can vouch for (ArenaMatch.lua's
-- answer handler asks Hop.Trusted). The match world stands Hop.Trusted in for each client
-- (tests/arena/lib/match-world.lua), so this file loads the real Hop.lua into the Shogun's client
-- and checks what that trust is now: a guildmate of his is listed, an officer of another Bankai Guild
-- guild only the census names is not (two cooperating characters can forge that rank while signed
-- enforcement is off). Every name is invented.
local H = ...
local test, eq = H.test, H.eq
local World = H.World
local MW = assert(loadfile(H.ROOT .. "tests/arena/lib/match-world.lua"))(H)

local SEEKER = { cont = 0, wx = -13000, wy = 300 }
local OTHER = { cont = 0, wx = -13400, wy = 250 }

-- An answer whispered to a searcher's client by `from`.
local function O(w, c, from, body) w:As(c, function() c.ns.Arena.Inject("WHISPER", from, "AM~L1~O~" .. body) end) end

test("1.2.1 the Shogun's match search: the real Hop.Trusted lists his guildmate, never an officer only the census names", function()
	local w = World.New()
	local shogun = MW.Client(w, World.NAMES.shogun, { guild = World.SHOGUN_GUILD, rank = 0, pos = SEEKER })
	local mate = MW.Client(w, "Mirela Stonecroft", { guild = World.SHOGUN_GUILD, rank = 3, pos = OTHER })
	local officer = "Orrin Valecourt-Emberfall" -- (plays on no client of this world)
	shogun.db.throneLocation = true
	-- The real Hop in the Shogun's client, in place of the world's stand-in.
	w:As(shogun, function() assert(loadfile(H.ADDON_DIR .. "Hop.lua"))("BankaiGuild", shogun.ns) end)
	assert(rawget(shogun.ns, "Hop") and shogun.ns.Hop.HandleAsk, "the real Hop")
	-- The Shogun's census names Orrin an officer of <Bankai Guild Ash>, as two of its reports would.
	shogun.rdb.guilds["Bankai Guild Ash"] = { total = 40, online = 4, zones = {}, t = w.clock, leader = "Leda Ashgrove",
		leaderOnline = false, officers = { { name = "Orrin Valecourt" } }, top = {} }
	shogun.ns.Data.KnownRank = function(n, g)
		if shogun.ns.FullName(n) == officer and g == "Bankai Guild Ash" then return 1, 2 end
		return nil
	end
	w:As(shogun, function()
		eq(shogun.ns.Hop.Trusted(mate.name), true, "a guildmate: our roster")
		eq(shogun.ns.Hop.Trusted(officer), false, "a census rank alone vouches for nobody")
		eq(shogun.ns.ArenaMatch.MemberOK(officer, "Bankai Guild Ash"), true, "he passes the member check: only trust drops him")
	end)
	assert(shogun.Match.Start({ game = "d", kind = "c", level = 0 }))
	eq(shogun.Match.View().search ~= nil, true, "the Shogun's search runs")
	O(w, shogun, officer, "9ix~f~Bankai Guild Ash~1~1o~1~d~c~0")
	O(w, shogun, mate.name, "9ix~f~" .. World.SHOGUN_GUILD .. "~1~1o~1~d~c~0")
	local names = {}
	for _, e in ipairs(shogun.Match.Ranked()) do names[#names + 1] = e.o.name end
	eq(table.concat(names, ","), mate.name, "only the guildmate is listed")
	MW.NoErrors(w)
end)
