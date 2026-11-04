-- The offline tests' world (11-02), as the addon was before ELFCORE emptied its pins: the shipped
-- Bankai Guild names no Shogun, Treasurer or author and has no name rule (only ELFCORE and BANKAI
-- by name). The tests were written for a world with them, so they are made up here, once, for
-- tests/run.lua and tests/sign-roundtrip.lua: a Shogun and his guild <Bankai Guild>, a Treasurer,
-- an author, and every guild with "Bankai Guild" in its name a member guild. Never loaded in game.
local ns = ...
ns.SHOGUN_CHARACTER = { Alliance = "Shobek Shobekler", Horde = "Duskmonkey Boneback" }
ns.SHOGUN_GUILD = { Alliance = "bankai guild", Horde = "mudhutters" }
ns.AUTHOR, ns.AUTHOR_REALM = "Faladoriel Skylance", "ClassicBetaPvP"
ns.TREASURER, ns.TREASURER_CHARACTERS = "Pyralis Ashandar", { "Pyralis Ashandar", "Pyralis Andarai" }
ns.APPROVED_BUILTIN = { Alliance = { "ELF", "ELVES" } }
ns.REMOVED_BUILTIN = { Alliance = { realm = ns.SHOGUN_REALM, "Bankai Guild Defense Force" } }
function ns.NameRule(guild)
	local g = guild:lower()
	return g:find("bankai guild", 1, true) ~= nil and not (g:find("anti", 1, true) or g:find("against", 1, true))
end

-- The Games ship closed (Core.lua's ns.GAMES_OPEN, 11-03); the test world opens them so the arena's
-- own tests run, and tests/arena/games-closed.lua closes them again on one client.
ns.GAMES_OPEN = true

-- The Treasurer role ships off (Core.lua's ns.TREASURER_ROLE, 11-03); the test world has one, so
-- the treasury's and the dues' own tests run as written, and one test turns it off again.
ns.TREASURER_ROLE = true

-- The Shogun's Gates ship off (Acts.GatesShown, 11-03); the test world turns them on so their own
-- tests run, and one test turns them off again.
ns.GATES_SHOWN = true
