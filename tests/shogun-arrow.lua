-- The Shogun's minimap-edge arrow: truthful location gates and independent, bounded controls.
local _, test, eq = ...
local ROOT = (debug.getinfo(1, "S").source:sub(2):match("^(.*)tests[/\\]shogun%-arrow%.lua$")) or "./"
local SHOGUN = "High Shogun-Realm"

local function Full(name)
	if type(name) ~= "string" or name == "" or name:find("-", 1, true) then return name end
	return name .. "-Realm"
end

local function Near(a, b, msg)
	if type(a) ~= "number" or math.abs(a - b) > 1e-6 then
		error((msg or "") .. " expected about " .. tostring(b) .. ", got " .. tostring(a), 2)
	end
end

-- The made-up world every test here stands in. Each map has HereBeDragons' own numbers for it (its
-- mapData: left and top edges, width and height in yards, and the world instance, the continent),
-- so a map x, y is the world point (left - width * x, top - height * y): HereBeDragons-2.0.lua,
-- GetWorldCoordinatesFromZone. Elwynn Forest lies east of Stormwind City (Stormwind's x 1 is
-- Elwynn's x 0); the Glimmerdeep Mine is a micro map inside Elwynn (its centre is Elwynn's
-- x 0.3667, y 0.3); Durotar is on another continent; the Unmapped Hollow has no world coordinates.
local MAPS = {
	[946] = { name = "Cosmic", mapType = 0 },
	[947] = { name = "Azeroth", mapType = 1, parent = 946 },
	[1415] = { name = "Eastern Kingdoms", mapType = 2, parent = 947, instance = 0, left = 20000, top = 20000, width = 40000, height = 40000 },
	[1414] = { name = "Kalimdor", mapType = 2, parent = 947, instance = 1, left = 20000, top = 20000, width = 40000, height = 40000 },
	[1453] = { name = "Stormwind City", mapType = 3, parent = 1415, instance = 0, left = 9000, top = 1000, width = 1000, height = 700 },
	[1429] = { name = "Elwynn Forest", mapType = 3, parent = 1415, instance = 0, left = 8000, top = 1500, width = 3000, height = 2000 },
	[1411] = { name = "Durotar", mapType = 3, parent = 1414, instance = 1, left = 1000, top = -3000, width = 4000, height = 4000 },
	[2998] = { name = "Glimmerdeep Mine", mapType = 5, parent = 1429, instance = 0, left = 7000, top = 1000, width = 200, height = 200 },
	[2999] = { name = "Unmapped Hollow", mapType = 3, parent = 1415, instance = 0 },
}

local function Vector(x, y)
	return { x = x, y = y, GetXY = function(self) return self.x, self.y end }
end

local function Frame(parent)
	local f = { parent = parent, shown = true, scripts = {}, center = { 150, 100 }, level = 2 }
	function f:SetSize(w, h) self.w, self.h = w, h end
	function f:GetWidth() return self.w or 140 end
	function f:GetHeight() return self.h or 140 end
	function f:SetPoint(...) self.point = { ... } end
	function f:ClearAllPoints() self.point = nil end
	function f:SetParent(p) self.parent = p end
	function f:SetFrameLevel(v) self.level = v end
	function f:GetFrameLevel() return self.level end
	-- Placed against another frame's centre (as the pin library places its pins), its centre is
	-- that one's plus the offset; otherwise the test's own.
	function f:GetCenter()
		local p = self.point
		if p and type(p[2]) == "table" and p[2].GetCenter then
			local rx, ry = p[2]:GetCenter()
			return rx + (p[4] or 0), ry + (p[5] or 0)
		end
		return self.center[1], self.center[2]
	end
	function f:EnableMouse(v) self.mouse = v end
	function f:SetScript(kind, call) self.scripts[kind] = call end
	function f:RegisterEvent() end
	function f:UnregisterAllEvents() end
	function f:Show() self.shown = true end
	function f:Hide() self.shown = false end
	function f:IsShown() return self.shown end
	function f:IsVisible() return self.shown end
	function f:GetZoom() return 0 end
	function f:SetZoom() end
	function f:GetScale() return 1 end
	function f:CreateTexture()
		local t = { alpha = 1 }
		function t:SetAtlas(atlas) self.atlas = atlas end
		function t:SetTexture(file) self.texture = file end
		function t:SetAllPoints() self.all = true end
		function t:SetBlendMode(mode) self.blend = mode end
		function t:SetAlpha(alpha) self.alpha = alpha end
		function t:SetRotation(rotation) self.rotation = rotation end
		function t:SetVertexColor(r, g, b) self.color = { r, g, b }; self.paints = (self.paints or 0) + 1 end
		function t:SetDesaturated(v) self.desaturated = v end
		function t:SetSize(w, h) self.w, self.h = w, h end
		function t:SetPoint(...) self.point = { ... } end
		return t
	end
	return f
end

-- options.real: the real LibStub, CallbackHandler, HereBeDragons and HereBeDragons-Pins (as
-- BankaiGuild.toc loads them) over this world, instead of the stand-in pins and map data.
local REAL_GLOBALS = { "WorldMapFrame", "C_Minimap", "C_Timer", "GetCVar", "GetPlayerFacing", "GetMinimapShape",
	"UnitPosition", "IsLoggedIn", "securecallfunction", "CreateVector2D", "Enum", "Mixin", "CreateFromMixins",
	"MapCanvasDataProviderMixin", "MapCanvasPinMixin", "CreateUnsecuredRegionPoolInstance", "CreateFramePool", "wipe",
	"Lerp", "WOW_PROJECT_ID", "WOW_PROJECT_MAINLINE", "WOW_PROJECT_CLASSIC", "WOW_PROJECT_BURNING_CRUSADE_CLASSIC",
	"WOW_PROJECT_WRATH_CLASSIC", "WOW_PROJECT_CATACLYSM_CLASSIC", "WOW_PROJECT_MISTS_CLASSIC",
	"HBD_PINS_WORLDMAP_SHOW_PARENT", "HBD_PINS_WORLDMAP_SHOW_CONTINENT", "HBD_PINS_WORLDMAP_SHOW_WORLD" }

local function LoadRealMapLibraries(w)
	WOW_PROJECT_MAINLINE, WOW_PROJECT_CLASSIC, WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 1, 2, 5
	WOW_PROJECT_WRATH_CLASSIC, WOW_PROJECT_CATACLYSM_CLASSIC, WOW_PROJECT_MISTS_CLASSIC = 11, 14, 19
	WOW_PROJECT_ID = WOW_PROJECT_MAINLINE
	Enum = setmetatable({ UIMapType = { Cosmic = 0, World = 1, Continent = 2, Zone = 3, Dungeon = 4, Micro = 5, Orphan = 6 } },
		{ __index = w.savedEnum })
	CreateVector2D = Vector
	securecallfunction = function(call, ...) return call(...) end
	IsLoggedIn = function() return false end
	C_Timer = { After = function() end }
	wipe = function(t) for k in pairs(t) do t[k] = nil end return t end
	Lerp = function(a, b, t) return a + (b - a) * t end
	w.cvars = { rotateMinimap = "0", minimapZoom = "0", minimapInsideZoom = "0" }
	GetCVar = function(name) return w.cvars[name] end
	w.facing = 0
	GetPlayerFacing = function() return w.facing end
	GetMinimapShape = nil
	C_Minimap = { GetViewRadius = function() return 100 end }
	-- The player's world position, from the same map numbers (UnitPosition: north first).
	UnitPosition = function(unit)
		local c = w.current
		local m = c and unit == "player" and not c.instance and MAPS[c.mapID]
		if not m or not m.left then return nil end
		return m.top - m.height * c.y, m.left - m.width * c.x, 0, m.instance
	end
	Mixin = function(object, ...)
		for i = 1, select("#", ...) do for k, v in pairs((select(i, ...))) do object[k] = v end end
		return object
	end
	CreateFromMixins = function(...) return Mixin({}, ...) end
	MapCanvasDataProviderMixin = { GetMap = function(self) return self.owningMap end }
	MapCanvasPinMixin = {}
	CreateUnsecuredRegionPoolInstance, CreateFramePool = function() return {} end, nil
	WorldMapFrame = Frame(UIParent)
	WorldMapFrame.pinPools = {}
	function WorldMapFrame:GetCanvas() return self end
	function WorldMapFrame:AddDataProvider(provider) provider.owningMap = self end
	LibStub = nil
	for _, file in ipairs({ "LibStub/LibStub.lua", "CallbackHandler-1.0/CallbackHandler-1.0.lua",
		"HereBeDragons/HereBeDragons-2.0.lua", "HereBeDragons/HereBeDragons-Pins-2.0.lua" }) do
		assert(loadfile(ROOT .. "BankaiGuild/libs/" .. file))()
	end
	w.lib, w.realHBD = LibStub("HereBeDragons-Pins-2.0"), LibStub("HereBeDragons-2.0")
	assert(w.realHBD.mapData[1429] and w.realHBD.mapData[1429].instance == 0, "the real library read the made-up maps")
	-- The library's own frame, a second on: a full update of every minimap pin.
	function w.tick(c) w.use(c, function() w.lib.updateFrame.scripts.OnUpdate(w.lib.updateFrame, 1.5) end) end
	-- The player entered another zone: the event the real library listens to.
	function w.zone(c)
		w.use(c, function() w.realHBD.eventFrame.scripts.OnEvent(w.realHBD.eventFrame, "ZONE_CHANGED_NEW_AREA") end)
	end
	function w.rotate(on)
		w.cvars.rotateMinimap = on and "1" or "0"
		w.lib.updateFrame.scripts.OnEvent(w.lib.updateFrame, "CVAR_UPDATE", "rotateMinimap", w.cvars.rotateMinimap)
	end
end

local function WithWorld(fn, options)
	options = options or {}
	local globals = { "CreateFrame", "UIParent", "Minimap", "GetGuildInfo", "IsInInstance", "C_Map",
		"C_Texture", "C_ChatInfo", "issecretvalue", "LibStub" }
	if options.real then for _, key in ipairs(REAL_GLOBALS) do globals[#globals + 1] = key end end
	local saved = {}
	for _, key in ipairs(globals) do saved[key] = rawget(_G, key) end
	local w = { clock = 1000, current = nil, logged = true, edge = true, atlas = options.atlas ~= false,
		mapCalls = 0, hbdCalls = 0, savedEnum = saved.Enum,
		location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1453, x = 0.62, y = 0.44, t = 1000 } }
	local ok, err = pcall(function()
		UIParent = Frame()
		Minimap = Frame(UIParent)
		Minimap.center = { 100, 100 }
		CreateFrame = function(_, _, parent) return Frame(parent) end
		GetGuildInfo = function() return w.current and w.current.guild or nil end
		IsInInstance = function() return w.current and w.current.instance == true or false end
		C_Map = {
			GetBestMapForUnit = function()
				w.mapCalls = w.mapCalls + 1
				return w.current and w.current.mapID or nil
			end,
			GetPlayerMapPosition = function(mapID)
				w.mapCalls = w.mapCalls + 1
				local c = w.current
				if not c or mapID ~= c.mapID or c.noPosition then return nil end
				return { GetXY = function() return c.x, c.y end }
			end,
			-- (The rest, for the real HereBeDragons reading its map data when it loads.)
			GetMapInfo = function(id)
				local m = MAPS[id]
				return m and { mapID = id, name = m.name, mapType = m.mapType, parentMapID = m.parent or 0 } or nil
			end,
			GetMapChildrenInfo = function(parent)
				local ids, list = {}, {}
				for id, m in pairs(MAPS) do if m.parent == parent then ids[#ids + 1] = id end end
				table.sort(ids)
				for _, id in ipairs(ids) do list[#list + 1] = C_Map.GetMapInfo(id) end
				return list
			end,
			GetMapGroupID = function() return nil end,
			GetWorldPosFromMapPos = function(id, v)
				local m = MAPS[id]
				if not m or not m.instance then return nil end
				if not m.left then return m.instance, nil end
				local x, y = v:GetXY()
				return m.instance, Vector(m.top - m.height * y, m.left - m.width * x)
			end,
			GetMapWorldSize = function(id)
				local m = MAPS[id]
				return m and m.width or 0, m and m.height or 0
			end,
		}
		C_Texture = { GetAtlasInfo = function() return w.atlas and {} or nil end }
		C_ChatInfo = { SendAddonMessageLogged = function() end }
		issecretvalue = function(value) return type(value) == "table" and value.secret == true end
		-- HereBeDragons as far as the arrow uses it (its world coordinates from its map data, as
		-- HereBeDragons-2.0.lua computes them); the tests with options.real use the real library.
		w.hbd = {}
		function w.hbd:GetWorldCoordinatesFromZone(x, y, zone)
			w.hbdCalls = w.hbdCalls + 1
			local m = MAPS[zone]
			if not m or not m.left or not x or not y then return nil, nil, nil end
			return m.left - m.width * x, m.top - m.height * y, m.instance
		end
		LibStub = function(name) if name == "HereBeDragons-2.0" then return w.hbd end end
		if options.real then LoadRealMapLibraries(w) end

		function w.use(c, call, ...)
			local before = w.current
			w.current = c
			local result = { n = 0 }
			local function capture(...)
				result.n = select("#", ...)
				for i = 1, result.n do result[i] = select(i, ...) end
			end
			capture(pcall(call, ...))
			w.current = before
			if not result[1] then error(result[2], 0) end
			return unpack(result, 2, result.n)
		end

		function w.client(name)
			local c = {
				me = Full(name or "Viewer"), realm = "Realm", guild = "Bankai Guild II", mapID = 1453,
				x = 0.35, y = 0.38, member = true, db = {}, rdb = {}, sent = {}, handlers = {}, listeners = {},
				prints = {}, council = {}, issuers = {}, moderators = {}, refreshes = 0,
				mine = { mapID = 1453, zoneUID = 8, t = w.clock },
				there = { mapID = 1453, zoneUID = 8, t = w.clock },
			}
			c.L = setmetatable({
				SHOGUN_ARROW_TITLE = "Minimap arrow to the Shogun", SHOGUN_ARROW_ON = "On", SHOGUN_ARROW_OFF = "Off",
				SHOGUN_ARROW_ENABLED = "arrow on", SHOGUN_ARROW_DISABLED = "arrow off", SHOGUN_ARROW_DENIED = "denied",
				SHOGUN_ARROW_USAGE = "usage", SHOGUN_ARROW_STATUS = "arrow: %s", SHOGUN_ARROW_GLOBAL_TIP = "global only",
				SHOGUN_ARROW_GUILD_TIP = "guild only",
			}, { __index = function(_, key) return key end })
			c.Now = function() return w.clock end
			c.CROWN_ICON = "Interface\\GroupFrame\\UI-Group-LeaderIcon"
			c.FullName = Full
			c.RealmOf = function(n) return type(n) == "string" and n:match("%-([^%-]+)$") or nil end
			c.DisplayName = function(n) return type(n) == "string" and n:gsub("%-.*$", "") or n end
			c.Fold = function(s) return tostring(s or ""):lower() end
			c.IsFederation = function(g) return type(g) == "string" and g:lower():find("bankaiguild", 1, true) ~= nil end
			c.IsMember = function() return c.member == true end
			c.IsShogunCharacter = function(n) return type(n) == "string" and n:lower() == SHOGUN:lower() end
			c.IsHighCouncillor = function(n) return c.council[tostring(n):lower()] == true end
			c.Data = { ServerTime = function() return w.clock end }
			c.Moderation = {
				missing = false,
				IsIssuer = function(n) return c.issuers[tostring(n):lower()] == true end,
				Hides = function(n) return c.hidden and c.hidden[tostring(n):lower()] or nil end,
			}
			c.Watch = { missing = false, IsAuthorized = function(n) return c.moderators[tostring(n):lower()] == true end }
			c.Shogun = {
				LOCATION_EXPIRE = 45,
				Location = function() return w.location end,
				ToggleLocation = function() c.crownToggles = (c.crownToggles or 0) + 1 end,
			}
			c.Layers = { Mine = function() return c.mine end, Of = function() return c.there end }
			c.UI = { Refresh = function() c.refreshes = c.refreshes + 1 end }
			c.Print = function(line) c.prints[#c.prints + 1] = line end
			c.On = function(event, call) c.listeners[event] = call end
			c.Every = function(seconds, key, call) c.timers = c.timers or {}; c.timers[key] = { seconds, call } end
			c.Comm = {
				Handle = function(kind, call) c.handlers[kind] = call end,
				DeliveredLogged = function() return w.logged end,
				Send = function(dist, msg, key, urgent, logged, done, sendOptions)
					c.sent[#c.sent + 1] = { dist = dist, msg = msg, key = key, logged = logged,
						done = done, options = sendOptions }
					return true
				end,
			}
			local pins = { adds = {}, worldAdds = {}, removes = {} }
			function pins:AddMinimapIconMap(ref, icon, mapID, x, y, parent, edge)
				-- As the library: no pin, and false, for a map without world coordinates
				-- (HereBeDragons-Pins-2.0.lua, AddMinimapIconMap).
				if not (MAPS[mapID] and MAPS[mapID].left) then return false end
				self.adds[#self.adds + 1] = { ref = ref, icon = icon, mapID = mapID, x = x, y = y,
					parent = parent, edge = edge }
				icon:Show()
				return true
			end
			function pins:AddMinimapIconWorld(ref, icon, instanceID, x, y, edge)
				self.worldAdds[#self.worldAdds + 1] = { ref = ref, icon = icon, instanceID = instanceID, x = x, y = y,
					edge = edge }
				icon:Show()
				return true
			end
			function pins:RemoveMinimapIcon(ref, icon)
				self.removes[#self.removes + 1] = { ref = ref, icon = icon }
				icon:Hide()
			end
			function pins:IsMinimapIconOnEdge() return w.edge end
			c.pins = options.real and w.lib or pins
			c.Pins = function() return c.pins end
			assert(loadfile(ROOT .. "BankaiGuild/ShogunArrow.lua"))("BankaiGuild", c)
			return c
		end

		fn(w)
	end)
	for _, key in ipairs(globals) do _G[key] = saved[key] end
	if not ok then error(err, 0) end
end

-- The tint the arrow's texture has now: "exact", "maybe", or nil for neither.
local function Tint(c)
	local icon = c.ShogunArrow.State().frame.icon
	for name, tint in pairs(c.ShogunArrow.TINTS) do
		if icon.color and icon.color[1] == tint.r and icon.color[2] == tint.g and icon.color[3] == tint.b
			and icon.desaturated == tint.desaturate then return name end
	end
	return nil
end

test("shogun arrow: a fresh authenticated crown on our exact fresh layer draws only a native minimap pointer", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		local target, why, certainty, world = w.use(c, c.ShogunArrow.Target)
		eq(target, w.location)
		eq(why, "shown"); eq(certainty, "exact"); eq(world, nil, "on his map: the map pin, limited to his map")
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(#c.pins.adds, 1)
		eq(#c.pins.worldAdds, 0)
		local frame = c.ShogunArrow.State().frame
		eq(frame.icon.atlas, c.ShogunArrow.NATIVE_ATLAS)
		eq(frame.icon.texture, nil, "the native atlas exists: no addon art or fallback used")
		eq(c.ShogunArrow.State().drawn.mapID, 1453)
		eq(c.ShogunArrow.State().reason, "shown")
		eq(c.ShogunArrow.State().certainty, "exact")
		eq(Tint(c), "exact", "untinted: white, never greyed")
		eq(c.crownToggles, nil, "drawing the arrow never toggles the crown")
		eq(frame.icon.alpha, 1, "a floating edge pointer is fully visible")
		-- SetRotation turns counter-clockwise (the game's own edge arrow turns by the negative of
		-- the clockwise angle: Blizzard_QuestNavigation/SuperTrackedFrame.lua, UpdateArrow). The pin
		-- sits right of the minimap's centre, so the up-pointing arrow turns a quarter clockwise.
		Near(frame.icon.rotation, -math.pi / 2, "the edge pointer points right, toward its pin")
		w.edge = false
		eq(w.use(c, c.ShogunArrow.UpdateDirection), false)
		eq(frame.icon.alpha, 0, "inside minimap range the existing crown is enough")
	end)
end)

-- Before: the pin to the right turned a quarter counter-clockwise, pointing left (and every pin
-- east or west of the player pointed the mirrored way).
test("shogun arrow: the edge pointer turns toward the pin on every side of the minimap", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		local frame = c.ShogunArrow.State().frame
		local sides = {
			{ { 150, 100 }, -math.pi / 2, "right" }, { { 50, 100 }, math.pi / 2, "left" },
			{ { 100, 150 }, 0, "up" }, { { 150, 150 }, -math.pi / 4, "up and right" },
			{ { 50, 50 }, 3 * math.pi / 4, "down and left" },
		}
		for _, side in ipairs(sides) do
			frame.center = side[1]
			eq(w.use(c, c.ShogunArrow.UpdateDirection), true)
			Near(frame.icon.rotation, side[2], side[3])
		end
		frame.center = { 100, 50 }
		eq(w.use(c, c.ShogunArrow.UpdateDirection), true)
		Near(math.abs(frame.icon.rotation), math.pi, "down")
	end)
end)

test("shogun arrow: native texture fallback works when the client lacks the atlas", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		local icon = c.ShogunArrow.State().frame.icon
		eq(icon.atlas, nil)
		eq(icon.texture, c.ShogunArrow.NATIVE_TEXTURE)
		assert(not icon.texture:find("AddOns", 1, true), "the fallback is still Blizzard art")
	end, { atlas = false })
end)

-- (Before 1.1.6 a stale layer report, another layer and another map were refusals here too; they
-- now show a tinted arrow, below.)
test("shogun arrow: offline, expired, forged, foreign and own crowns still fail closed", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		w.location = nil
		eq(select(2, w.use(c, c.ShogunArrow.Target)), "offline")
		w.location = { from = SHOGUN, mapID = 1453, x = 0.6, y = 0.4, t = w.clock - 46 }
		eq(select(2, w.use(c, c.ShogunArrow.Target)), "offline")
		w.location.t = w.clock
		w.location.from = "Pretender-Realm"
		eq(select(2, w.use(c, c.ShogunArrow.Target)), "identity")
		w.location.from = SHOGUN
		local foreign = w.client("Traveller-Elsewhere")
		foreign.realm = "Elsewhere"
		eq(select(2, w.use(foreign, foreign.ShogunArrow.Target)), "realm")
		w.location.x = 1.5
		eq(select(2, w.use(c, c.ShogunArrow.Target)), "position")
		w.location.x = 0.6
		c.me = SHOGUN
		eq(select(2, w.use(c, c.ShogunArrow.Target)), "self")
	end)
end)

-- Fails on the code before 1.1.6: every one of these was a refusal ("layer-stale" or "layer") and
-- no arrow at all.
test("shogun arrow: on his map with another or an unknown layer the arrow still shows, tinted as unsure", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		c.mine.t = w.clock - c.ShogunArrow.LAYER_FRESH - 1
		eq(w.use(c, c.ShogunArrow.Refresh), true, "our layer report is stale: still an arrow")
		local at, why, certainty, world = w.use(c, c.ShogunArrow.Target)
		eq(at, w.location); eq(why, "layer-stale"); eq(certainty, "maybe"); eq(world, nil)
		local TINTS = c.ShogunArrow.TINTS
		assert(TINTS.maybe.a < TINTS.exact.a, "the unsure arrow is fainter than the certain one")
		local frame = c.ShogunArrow.State().frame
		eq(#c.pins.adds, 1, "his map's pin, as for the certain arrow")
		eq(c.pins.adds[1].mapID, 1453)
		eq(c.ShogunArrow.State().reason, "layer-stale")
		eq(c.ShogunArrow.State().certainty, "maybe")
		eq(Tint(c), "maybe")
		eq(frame.icon.alpha, TINTS.maybe.a)
		-- His report missing altogether is unknown too.
		c.mine.t = w.clock
		c.there = nil
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(c.ShogunArrow.State().reason, "layer-stale")
		eq(Tint(c), "maybe")
		-- Both fresh, another layer.
		c.there = { mapID = 1453, zoneUID = 9, t = w.clock }
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(c.ShogunArrow.State().reason, "layer")
		eq(Tint(c), "maybe")
		eq(frame.icon.alpha, TINTS.maybe.a)
		-- Our fresh report is from another map: it says nothing of his layer here.
		c.there.zoneUID = 8
		c.mine = { mapID = 1429, zoneUID = 8, t = w.clock }
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(c.ShogunArrow.State().reason, "layer")
		-- Agreeing again: the certain arrow, the same pin (a tint never moves it).
		c.mine = { mapID = 1453, zoneUID = 8, t = w.clock }
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(c.ShogunArrow.State().reason, "shown")
		eq(c.ShogunArrow.State().certainty, "exact")
		eq(Tint(c), "exact")
		eq(frame.icon.alpha, TINTS.exact.a)
		eq(#c.pins.adds, 1, "never pinned again for a tint")
		eq(#c.pins.removes, 0)
		-- And unsure again once the reports go stale.
		w.clock = w.clock + c.ShogunArrow.LAYER_FRESH + 1
		w.location.t = w.clock
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(c.ShogunArrow.State().reason, "layer-stale")
		eq(Tint(c), "maybe")
	end)
end)

-- Fails on the code before 1.1.6: another map was the refusal "map".
test("shogun arrow: in another zone of his continent a world pin at his world position, tinted as unsure", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.5, y = 0.425, t = w.clock }
		c.mine = { mapID = 1453, zoneUID = 8, t = w.clock }
		c.there = { mapID = 1429, zoneUID = 8, t = w.clock }
		local at, why, certainty, world = w.use(c, c.ShogunArrow.Target)
		eq(at, w.location); eq(why, "zone"); eq(certainty, "maybe")
		-- Elwynn Forest's x 0.5, y 0.425 in its world yards (left - width * x, top - height * y).
		eq(world.instanceID, 0); Near(world.wx, 6500); Near(world.wy, 650)
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(#c.pins.adds, 0, "no map pin: the library shows those only on his map")
		eq(#c.pins.worldAdds, 1)
		local add = c.pins.worldAdds[1]
		eq(add.ref, c.ShogunArrow.State().pinRef)
		eq(add.icon, c.ShogunArrow.State().frame)
		eq(add.instanceID, 0); Near(add.x, 6500); Near(add.y, 650)
		eq(add.edge, true, "it floats on the minimap's edge")
		eq(c.ShogunArrow.State().mode, "world")
		eq(c.ShogunArrow.State().reason, "zone")
		eq(Tint(c), "maybe", "layers cannot be compared across zones")
		eq(c.ShogunArrow.State().frame.icon.alpha, c.ShogunArrow.TINTS.maybe.a)
		-- Even reports naming the same zone UID never make it certain from another zone.
		c.mine = { mapID = 1429, zoneUID = 8, t = w.clock }
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(c.ShogunArrow.State().certainty, "maybe")
		eq(c.crownToggles, nil)
	end)
end)

-- Fails on the code before this fix: from another zone the arrow was transparent inside the
-- minimap's range ("the crown is enough"), but his crown is a map pin the library draws only on his
-- map or a zone above it, so nothing marked him (the verifier's case: the Shogun just outside a city
-- gate, his fans just inside).
test("shogun arrow: from another zone inside the minimap's range a faded crown marks his spot", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.5, y = 0.425, t = w.clock }
		local TINTS, State = c.ShogunArrow.TINTS, c.ShogunArrow.State
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(State().reason, "zone"); eq(State().mark, true, "his crown is not drawn from Stormwind City")
		local frame = State().frame
		local mark = frame.mark
		assert(mark, "a crown marker in the arrow's frame")
		eq(mark.texture, c.CROWN_ICON, "the crown's own art")
		eq(mark.w, 16); eq(mark.h, 16)
		eq(mark.point[1], "CENTER"); eq(mark.point[2], frame)
		eq(mark.desaturated, true, "tinted as unsure, as the arrow")
		eq(mark.color[1], TINTS.maybe.r); eq(mark.color[2], TINTS.maybe.g); eq(mark.color[3], TINTS.maybe.b)
		-- On the edge: the arrow, no crown.
		eq(frame.icon.alpha, TINTS.maybe.a); eq(mark.alpha, 0)
		-- Inside the range: the crown at his spot, faded, upright; the arrow transparent.
		w.edge = false
		eq(w.use(c, c.ShogunArrow.UpdateDirection), false)
		eq(frame.icon.alpha, 0)
		eq(mark.alpha, TINTS.maybe.a)
		eq(mark.rotation, nil, "the crown is never turned")
		for _ = 1, 5 do w.use(c, frame.scripts.OnUpdate, frame, 0.1) end
		eq(mark.alpha, TINTS.maybe.a, "it stays while he is in range")
		-- Out of range again: the arrow comes back, the crown goes.
		w.edge = true
		eq(w.use(c, c.ShogunArrow.UpdateDirection), true)
		eq(frame.icon.alpha, TINTS.maybe.a); eq(mark.alpha, 0)
		-- Not placed by the library (no edge answer): neither.
		w.edge = nil
		eq(w.use(c, c.ShogunArrow.UpdateDirection), false)
		eq(frame.icon.alpha, 0); eq(mark.alpha, 0)
		-- On his map his own crown is drawn: inside the range nothing of ours, as before.
		w.edge = false
		c.mapID = 1429
		c.mine = { mapID = 1429, zoneUID = 8, t = w.clock }
		c.there = { mapID = 1429, zoneUID = 8, t = w.clock }
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(State().mode, "map"); eq(State().mark, false)
		eq(frame.icon.alpha, 0); eq(mark.alpha, 0)
		-- Back into the city, still in range: the faded crown again.
		c.mapID = 1453
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(State().mode, "world"); eq(mark.alpha, TINTS.maybe.a)
		-- His lease expires: everything goes.
		w.clock = w.clock + 46
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(State().reason, "offline"); eq(State().mark, nil)
		eq(mark.alpha, 0); eq(frame.shown, false)
		-- Disabled by the controls while he is in range from another zone: nothing either.
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.5, y = 0.425, t = w.clock }
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(mark.alpha, TINTS.maybe.a)
		local moderator = "Moderator-Realm"
		c.moderators[moderator:lower()] = true
		eq(w.use(c, c.ShogunArrow.Handle, "GUILD", moderator, ("K6~1~L~0~%d~Bankai Guild II"):format(w.clock)), true)
		eq(State().reason, "disabled"); eq(mark.alpha, 0); eq(frame.shown, false)
	end)
end)

test("shogun arrow: another continent, an instance or a map without world coordinates draws nothing and says why", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.5, y = 0.425, t = w.clock }
		c.mapID = 1411
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(c.ShogunArrow.State().reason, "continent")
		eq(#c.pins.adds + #c.pins.worldAdds, 0)
		c.mapID = 2999
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(c.ShogunArrow.State().reason, "world", "no world coordinates for our map")
		c.mapID = 1453
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 2999, x = 0.5, y = 0.5, t = w.clock }
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(c.ShogunArrow.State().reason, "world", "no world coordinates for his map")
		-- Both on that map: the library has no pin for it either (before: "pin-api").
		c.mapID = 2999
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(c.ShogunArrow.State().reason, "world", "no world coordinates for the map we share")
		eq(c.ShogunArrow.State().drawn, nil)
		c.mapID = 1453
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.5, y = 0.425, t = w.clock }
		c.instance = true
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(c.ShogunArrow.State().reason, "instance", "a dungeon, a raid or a battleground")
		c.instance = nil
		c.mapID = nil
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(c.ShogunArrow.State().reason, "map")
		c.mapID = 1453
		c.noPosition = true
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(c.ShogunArrow.State().reason, "player-position")
		c.noPosition = nil
		local saved = LibStub
		LibStub = nil
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(c.ShogunArrow.State().reason, "map-api", "without HereBeDragons no zone can be compared")
		LibStub = saved
		eq(#c.pins.adds + #c.pins.worldAdds, 0, "nothing drawn by any of these")
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(c.ShogunArrow.State().reason, "zone")
	end)
end)

test("shogun arrow: walking between his map, other zones and other continents swaps the pin and its tint", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.5, y = 0.425, t = w.clock }
		c.mapID = 1429
		c.mine = { mapID = 1429, zoneUID = 8, t = w.clock }
		c.there = { mapID = 1429, zoneUID = 8, t = w.clock }
		local State = c.ShogunArrow.State
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(State().mode, "map"); eq(State().certainty, "exact"); eq(#c.pins.adds, 1)
		-- Into Stormwind City: his map pin goes, his world pin comes, unsure.
		c.mapID = 1453
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(State().mode, "world"); eq(State().reason, "zone"); eq(Tint(c), "maybe")
		eq(#c.pins.removes, 1); eq(#c.pins.worldAdds, 1)
		-- Still there: nothing moves.
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(#c.pins.worldAdds, 1); eq(#c.pins.removes, 1)
		-- Over the sea to Durotar: gone.
		c.mapID = 1411
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(State().reason, "continent"); eq(State().drawn, nil)
		eq(#c.pins.removes, 2)
		eq(State().frame.shown, false)
		-- Back to Stormwind City, then into his forest on his layer.
		c.mapID = 1453
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(State().mode, "world"); eq(#c.pins.worldAdds, 2)
		c.mapID = 1429
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(State().mode, "map"); eq(State().reason, "shown"); eq(Tint(c), "exact")
		eq(#c.pins.adds, 2); eq(#c.pins.removes, 3)
		eq(State().frame.icon.alpha, 1)
	end)
end)

test("shogun arrow: his world position is converted once per position his lease reports; moving and expiring follow it", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.5, y = 0.425, t = w.clock }
		local stats = c.ShogunArrow.State().stats
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(stats.world, 1)
		for _ = 1, 5 do
			w.clock = w.clock + 1
			eq(w.use(c, c.ShogunArrow.Refresh), true)
		end
		eq(stats.world, 1, "five refreshes of the same position: no conversion again")
		eq(#c.pins.worldAdds, 1)
		-- His next report (a new table each time, Shogun.lua OnLocation) at the same spot: the same.
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.5, y = 0.425, t = w.clock }
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(stats.world, 1); eq(#c.pins.worldAdds, 1)
		-- He walks on: converted again, the pin follows him.
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.6, y = 0.425, t = w.clock }
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(stats.world, 2)
		eq(#c.pins.worldAdds, 2); eq(#c.pins.removes, 1)
		Near(c.pins.worldAdds[2].x, 8000 - 3000 * 0.6)
		-- He walks into our city: his map now, a map pin.
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1453, x = 0.62, y = 0.44, t = w.clock }
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(c.ShogunArrow.State().mode, "map"); eq(#c.pins.adds, 1)
		-- His lease expires (no report for longer than the crown keeps him): gone.
		w.clock = w.clock + 46
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(c.ShogunArrow.State().reason, "offline"); eq(c.ShogunArrow.State().drawn, nil)
		eq(c.ShogunArrow.State().frame.shown, false)
		-- He hides his crown: gone too.
		w.location = nil
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(c.ShogunArrow.State().reason, "offline")
	end)
end)

test("shogun arrow: the frame's OnUpdate reads no map, converts nothing and repaints nothing", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.5, y = 0.425, t = w.clock }
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		local frame = c.ShogunArrow.State().frame
		local maps, conversions, paints = w.mapCalls, w.hbdCalls, frame.icon.paints
		for _ = 1, 50 do w.use(c, frame.scripts.OnUpdate, frame, 0.05) end
		eq(w.mapCalls, maps, "no C_Map call per frame")
		eq(w.hbdCalls, conversions, "no HereBeDragons call per frame")
		eq(frame.icon.paints, paints, "the tint is set when it changes, not per frame")
		eq(frame.icon.alpha, c.ShogunArrow.TINTS.maybe.a, "and the rotation still runs")
		-- A refresh with the same lease and tint: one map read for us, his position not converted.
		w.use(c, c.ShogunArrow.Refresh)
		eq(frame.icon.paints, paints)
		eq(c.ShogunArrow.State().stats.world, 1)
	end)
end)

-- Fails on the code before 1.1.6: there was no arrow off his map.
test("shogun arrow, the real map libraries: in another zone of his continent the arrow floats on the edge toward him and turns with the minimap", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		-- He stands in Elwynn Forest, due east of us in Stormwind City (the same world instance).
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.5, y = 0.425, t = w.clock }
		c.mapID, c.x, c.y = 1453, 0.2, 0.5
		w.zone(c)
		-- The cause, in the library itself: a pin given by his map is shown only on his map.
		local probe = Frame(UIParent)
		w.lib:AddMinimapIconMap("Probe", probe, 1429, 0.5, 0.425, true, true)
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		w.tick(c)
		eq(w.lib.activeMinimapPins[probe], nil, "his map's pin is not drawn from Stormwind City")
		eq(probe.point, nil)
		local f = c.ShogunArrow.State().frame
		assert(w.lib.activeMinimapPins[f], "the arrow's world pin is drawn")
		eq(f.shown, true)
		eq(f.parent, Minimap, "parented to the minimap by the library, as before")
		eq(w.lib:IsMinimapIconOnEdge(f), true, "2300 yards away: on the edge")
		eq(w.use(c, c.ShogunArrow.UpdateDirection), true)
		Near(f.icon.rotation, -math.pi / 2, "east: the arrow points right")
		eq(f.icon.alpha, c.ShogunArrow.TINTS.maybe.a)
		eq(Tint(c), "maybe")
		-- Into his forest, on his layer: the certain arrow on his map's pin, still pointing east.
		c.mapID, c.x, c.y = 1429, 0.2, 0.425
		c.mine = { mapID = 1429, zoneUID = 8, t = w.clock }
		c.there = { mapID = 1429, zoneUID = 8, t = w.clock }
		w.zone(c)
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		w.tick(c)
		eq(c.ShogunArrow.State().mode, "map")
		assert(w.lib.activeMinimapPins[f], "his map's pin is drawn on his map")
		eq(w.use(c, c.ShogunArrow.UpdateDirection), true)
		Near(f.icon.rotation, -math.pi / 2)
		eq(f.icon.alpha, 1); eq(Tint(c), "exact")
		-- Back in the city with a rotating minimap, facing west: he is behind us, at the bottom.
		c.mapID, c.x, c.y = 1453, 0.2, 0.5
		w.zone(c)
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		w.facing = math.pi / 2
		w.rotate(true)
		w.tick(c)
		eq(w.use(c, c.ShogunArrow.UpdateDirection), true)
		Near(math.abs(f.icon.rotation), math.pi, "the arrow follows the rotated pin: down")
		w.rotate(false)
		-- Over the sea to Durotar: the library hides it at once, the arrow takes it off.
		c.mapID, c.x, c.y = 1411, 0.5, 0.5
		w.zone(c)
		eq(w.lib.activeMinimapPins[f], nil, "another world instance: not drawn")
		eq(f.shown, false)
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(c.ShogunArrow.State().reason, "continent")
		eq(w.lib.minimapPins[f], nil, "no pin of ours left in the library")
		-- Both in a map the library has no world coordinates for: it refuses his map's pin.
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 2999, x = 0.5, y = 0.5, t = w.clock }
		c.mapID, c.x, c.y = 2999, 0.4, 0.4
		w.zone(c)
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(c.ShogunArrow.State().reason, "world")
		eq(w.lib.minimapPins[f], nil)
	end, { real = true })
end)

-- Fails on the code before this fix (the verifier's reproduction): across the city's border, a few
-- dozen yards from him, neither his crown nor the arrow showed.
test("shogun arrow, the real map libraries: across a zone border inside the minimap's range the faded crown marks him, never doubling his own", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		local TINTS = c.ShogunArrow.TINTS
		-- He stands just outside the gate, in Elwynn Forest; we stand just inside Stormwind City,
		-- 45 yards west of him (the minimap shows 0.9 of its 100 yards' radius).
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.005, y = 0.425, t = w.clock }
		c.mapID, c.x, c.y = 1453, 0.97, 0.5
		w.zone(c)
		-- His crown, added as Shogun.lua RefreshCrown adds it.
		local crown = Frame(UIParent)
		w.lib:AddMinimapIconMap("Crown", crown, 1429, 0.005, 0.425, true, true)
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		w.tick(c)
		eq(c.ShogunArrow.State().reason, "zone"); eq(c.ShogunArrow.State().mode, "world")
		eq(w.lib.activeMinimapPins[crown], nil, "his crown is not drawn from Stormwind City")
		local f = c.ShogunArrow.State().frame
		assert(w.lib.activeMinimapPins[f], "the arrow's world pin is drawn")
		eq(f.shown, true)
		eq(w.lib:IsMinimapIconOnEdge(f), false, "in range: not on the edge")
		eq(w.use(c, c.ShogunArrow.UpdateDirection), false)
		eq(f.icon.alpha, 0, "no arrow in range")
		assert(f.mark, "a crown marker in the arrow's frame")
		eq(f.mark.alpha, TINTS.maybe.a, "the faded crown marks him")
		eq(f.mark.desaturated, true)
		-- Placed by the library 45 yards east of the minimap's centre (70 pixels across 100 yards).
		local fx, fy = f:GetCenter()
		local mx, my = Minimap:GetCenter()
		Near(fx - mx, 45 / 100 * 70, "east of us"); Near(fy - my, 0)
		-- He walks away east, beyond the range: the arrow on the edge, the crown gone.
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.5, y = 0.425, t = w.clock }
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		w.tick(c)
		eq(w.lib:IsMinimapIconOnEdge(f), true)
		eq(w.use(c, c.ShogunArrow.UpdateDirection), true)
		eq(f.icon.alpha, TINTS.maybe.a); eq(f.mark.alpha, 0)
		w.lib:RemoveMinimapIcon("Crown", crown)
		-- He goes down the Glimmerdeep Mine, a micro map inside Elwynn, and we stand in Elwynn at its
		-- mouth: the library draws his crown from his parent zone, so ours stays transparent.
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 2998, x = 0.5, y = 0.5, t = w.clock }
		c.mapID, c.x, c.y = 1429, 0.38, 0.3
		w.zone(c)
		w.lib:AddMinimapIconMap("Crown", crown, 2998, 0.5, 0.5, true, true)
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		w.tick(c)
		eq(c.ShogunArrow.State().reason, "zone"); eq(c.ShogunArrow.State().mark, false)
		assert(w.lib.activeMinimapPins[crown], "his crown is drawn from the zone above his mine")
		eq(w.lib:IsMinimapIconOnEdge(f), false)
		eq(w.use(c, c.ShogunArrow.UpdateDirection), false)
		eq(f.icon.alpha, 0); eq(f.mark.alpha, 0, "never a second crown over his")
		w.lib:RemoveMinimapIcon("Crown", crown)
		-- The other way round: we are in the mine, he is in Elwynn at its mouth. The library climbs
		-- only from his map upward, so his crown is not drawn in the mine: ours marks him.
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.38, y = 0.3, t = w.clock }
		c.mapID, c.x, c.y = 2998, 0.5, 0.5
		w.zone(c)
		w.lib:AddMinimapIconMap("Crown", crown, 1429, 0.38, 0.3, true, true)
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		w.tick(c)
		eq(c.ShogunArrow.State().mark, true)
		eq(w.lib.activeMinimapPins[crown], nil, "his crown is not drawn in the mine")
		eq(w.lib:IsMinimapIconOnEdge(f), false)
		eq(w.use(c, c.ShogunArrow.UpdateDirection), false)
		eq(f.icon.alpha, 0); eq(f.mark.alpha, TINTS.maybe.a)
		-- Over the sea: the library hides our pin, the arrow takes it off, no crown left.
		c.mapID, c.x, c.y = 1411, 0.5, 0.5
		w.zone(c)
		eq(w.use(c, c.ShogunArrow.Refresh), false)
		eq(c.ShogunArrow.State().reason, "continent")
		eq(f.shown, false); eq(f.mark.alpha, 0)
	end, { real = true })
end)

test("shogun arrow controls: Shogun and current Council control the global lease; Watch moderators control only their guild", function()
	WithWorld(function(w)
		local c = w.client("Council")
		c.council[c.me:lower()], c.issuers[c.me:lower()] = true, true
		eq(w.use(c, c.ShogunArrow.CanControl), true)
		eq(select(2, w.use(c, c.ShogunArrow.CanControl)), "global")
		eq(w.use(c, c.ShogunArrow.SetEnabled, false, "global", true), true)
		eq(c.ShogunArrow.Enabled(), false)
		eq(c.db.shogunArrowControl.scope, "global")
		eq(c.sent[1].dist, "CHANNEL")
		assert(c.sent[1].msg:match("^K6~1~G~0~%d+~$"), c.sent[1].msg)
		eq(c.crownToggles, nil, "the independent switch never touches the crown")
		-- Authority is checked again at the real send boundary.
		c.issuers[c.me:lower()] = nil
		local allowed, why = c.sent[1].options.guard()
		eq(allowed, false); eq(why, "revoked")

		local g = w.client("Moderator")
		g.moderators[g.me:lower()] = true
		eq(select(2, w.use(g, g.ShogunArrow.CanControl)), "guild")
		eq(w.use(g, g.ShogunArrow.SetEnabled, false, nil, true), true)
		eq(g.sent[1].dist, "GUILD")
		assert(g.sent[1].msg:match("^K6~1~L~0~%d+~Bankai Guild II$"), g.sent[1].msg)
		eq(#w.use(g, g.ShogunArrow.ControlLines), 1, "the Watch exposes the one independent toggle")

		local outsider = w.client("Outsider")
		eq(w.use(outsider, outsider.ShogunArrow.SetEnabled, false, nil, true), false)
		eq(#outsider.sent, 0)
	end)
end)

test("shogun arrow controls: server-stamped fresh authority wins; forged, unlogged, stale and replayed words do not", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		local council = "Council-Realm"
		c.council[council:lower()], c.issuers[council:lower()] = true, true
		w.logged = false
		eq(w.use(c, c.ShogunArrow.Handle, "CHANNEL", council, "K6~1~G~0~1000~"), false)
		eq(c.ShogunArrow.Enabled(), true, "an unlogged control is ignored where logged messages exist")
		w.logged = true
		eq(w.use(c, c.ShogunArrow.Handle, "CHANNEL", "Forged-Realm", "K6~1~G~0~1000~"), false)
		eq(w.use(c, c.ShogunArrow.Handle, "CHANNEL", council, "K6~1~G~0~1000~"), true)
		eq(c.ShogunArrow.Enabled(), false)
		eq(w.use(c, c.ShogunArrow.Handle, "CHANNEL", council, "K6~1~G~1~999~"), false, "older replay")
		eq(c.ShogunArrow.Enabled(), false)
		eq(w.use(c, c.ShogunArrow.Handle, "CHANNEL", council, "K6~1~G~1~1~"), false, "stale")
		eq(w.use(c, c.ShogunArrow.Handle, "GUILD", council, "K6~1~G~1~1001~"), false, "wrong lane")
		w.clock = w.clock + c.ShogunArrow.CONTROL_LEASE + 1
		eq(c.ShogunArrow.Enabled(), true, "an offline controller's lease cannot disable the arrow forever")

		local moderator = "Moderator-Realm"
		c.moderators[moderator:lower()] = true
		local now = w.clock
		eq(w.use(c, c.ShogunArrow.Handle, "GUILD", moderator, ("K6~1~L~0~%d~Bankai Guild III"):format(now)), false,
			"another guild cannot change this guild's arrow")
		eq(w.use(c, c.ShogunArrow.Handle, "GUILD", moderator, ("K6~1~L~0~%d~Bankai Guild II"):format(now)), true)
		eq(w.use(c, c.ShogunArrow.Enabled), false)
	end)
end)

test("shogun arrow controls: rank before recency: a High Councillor's newer 'on' never beats the Shogun's 'off' in force, and his client's repeat never stamps it again past the Shogun's word", function()
	WithWorld(function(w)
		local c = w.client("Council")
		c.council[c.me:lower()], c.issuers[c.me:lower()] = true, true
		eq(w.use(c, c.ShogunArrow.SetEnabled, true, "global", true), true)
		w.clock = w.clock + 10
		eq(w.use(c, c.ShogunArrow.Handle, "CHANNEL", SHOGUN, ("K6~1~G~0~%d~"):format(w.clock)), true, "the Shogun's off")
		eq(c.ShogunArrow.Enabled(), false)
		local v = w.client("Viewer")
		v.council[c.me:lower()], v.issuers[c.me:lower()] = true, true
		eq(w.use(v, v.ShogunArrow.Handle, "CHANNEL", SHOGUN, ("K6~1~G~0~%d~"):format(w.clock)), true)
		eq(w.use(v, v.ShogunArrow.Handle, "CHANNEL", c.me, ("K6~1~G~1~%d~"):format(w.clock + 5)), false, "a councillor's newer on")
		eq(v.ShogunArrow.Enabled(), false, "the Shogun's off stands")
		-- The councillor's own repeat: nothing goes out, even once the Shogun's word has lapsed.
		local sent = #c.sent
		eq(w.use(c, c.ShogunArrow.RepeatOwn), false)
		w.clock = w.clock + c.ShogunArrow.CONTROL_LEASE + 1
		eq(w.use(c, c.ShogunArrow.RepeatOwn), false, "never past the Shogun's later word")
		eq(#c.sent, sent)
		-- A lapsed word gives way: the councillor's new choice is taken.
		eq(w.use(v, v.ShogunArrow.Handle, "CHANNEL", c.me, ("K6~1~G~1~%d~"):format(w.clock)), true)
		eq(v.ShogunArrow.Enabled(), true)
	end)
end)

-- 1.2.5.1, review of the quiet presence (Core.lua): a controller's client stamped his word again
-- every five minutes, each repeat saying he was online. His own switch is his act and goes.
test("shogun arrow controls: while the quiet presence is on, his word is not repeated (his own switch still goes); the repeat comes back once off", function()
	WithWorld(function(w)
		local c = w.client("Council")
		c.council[c.me:lower()], c.issuers[c.me:lower()] = true, true
		local quiet = true
		c.QuietPresence = function() return quiet end
		eq(w.use(c, c.ShogunArrow.SetEnabled, false, "global", true), true, "his own switch")
		eq(#c.sent, 1)
		w.clock = w.clock + c.ShogunArrow.CONTROL_REPEAT
		eq(w.use(c, c.ShogunArrow.RepeatOwn), false)
		eq(#c.sent, 1, "no repeat while it is on")
		quiet = false
		eq(w.use(c, c.ShogunArrow.RepeatOwn), true)
		eq(#c.sent, 2)
		assert(c.sent[2].msg:match("^K6~1~G~0~%d+~$"), c.sent[2].msg)
	end)
end)

test("shogun arrow: disabling removes its pin and leaves every crown/location fact intact", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		local original = w.location
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		local council = "Council-Realm"
		c.council[council:lower()], c.issuers[council:lower()] = true, true
		eq(w.use(c, c.ShogunArrow.Handle, "CHANNEL", council, "K6~1~G~0~1000~"), true)
		eq(#c.pins.removes, 1)
		eq(c.ShogunArrow.State().drawn, nil)
		eq(c.ShogunArrow.State().reason, "disabled")
		eq(w.location, original)
		eq(c.Shogun.Location(), original)
		eq(c.crownToggles, nil)
		eq(c.mine.zoneUID, 8); eq(c.there.zoneUID, 8)
	end)
end)

test("shogun arrow: disabling from another zone removes its world pin too", function()
	WithWorld(function(w)
		local c = w.client("Viewer")
		w.location = { from = SHOGUN, name = "Shobek", id = 77, mapID = 1429, x = 0.5, y = 0.425, t = w.clock }
		eq(w.use(c, c.ShogunArrow.Refresh), true)
		eq(#c.pins.worldAdds, 1)
		local moderator = "Moderator-Realm"
		c.moderators[moderator:lower()] = true
		eq(w.use(c, c.ShogunArrow.Handle, "GUILD", moderator, "K6~1~L~0~1000~Bankai Guild II"), true)
		eq(#c.pins.removes, 1)
		eq(c.ShogunArrow.State().reason, "disabled")
		eq(c.ShogunArrow.State().frame.shown, false)
	end)
end)
