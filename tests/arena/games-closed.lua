-- The Games' switch (ns.GAMES_OPEN, unset in Core.lua: closed as the addon ships, 11-03): closed, no Games
-- tab, and every game command (/bka, /bk arena, bones, lottery...) only says so; the engine still
-- loads. The test world opens them (tests/world.lua), so this client closes them for itself.
local H = ...
local test, eq = H.test, H.eq
local World = H.World

test("the Games are closed: no Games tab, and /bka and /bk arena only say so", function()
	local w = World.New()
	local c = w:Client(World.NAMES.fighterA)
	local A, Home = c.ns.Arena, c.ns.ArenaHome
	eq(A.Closed(), false, "open in the test world")
	rawset(c.ns, "GAMES_OPEN", false)
	w:As(c, function()
		eq(A.Closed(), true)
		eq(Home.TabVisible(), false, "no Games tab")
		local ok, why = A.RunSlash("")
		eq(ok, false); eq(why, "closed")
		local ok2, why2 = A.RunSlash("say hi") -- (/bka <text>)
		eq(ok2, false); eq(why2, "closed")
	end)
	eq(c.printed[#c.printed], c.ns.L.ARENA_CLOSED)
	rawset(c.ns, "GAMES_OPEN", true)
	eq(A.Closed(), false, "one line opens them")
end)
