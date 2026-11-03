-- The configured crown consent remains independent of actual current map publishability.
local H = ...
local test, eq = H.test, H.eq
local function Setup()
	local w = H.World.New({ compliance = "shipped" })
	local shogun = w:Role("shogun")
	shogun.mapID, shogun.x, shogun.y = 1453, 0.42, 0.51
	shogun.globals.C_Map = {
		GetBestMapForUnit = function() return shogun.mapID end,
		GetPlayerMapPosition = function()
			if shogun.noPosition then return nil end
			return { GetXY = function() return shogun.x, shogun.y end }
		end,
	}
	shogun.db.throneLocation = true
	return w, shogun
end
local function PositionSends(w)
	local n = 0
	for _, packet in ipairs(w.sent) do if packet.msg:match("^T1~P~") then n = n + 1 end end
	return n
end
local function Has(lines, text)
	for _, line in ipairs(lines) do if line.text and line.text:find(text, 1, true) then return true end end
	return false
end

test("Shogun effective map status: real Throne banner never claims live inside an instance or without coordinates", function()
	for _, blocked in ipairs({ "instance", "missing", "zero", "invalid" }) do
		local w, shogun = Setup()
		if blocked == "instance" then shogun.instance = true
		elseif blocked == "missing" then shogun.noPosition = true
		elseif blocked == "zero" then shogun.x, shogun.y = 0, 0
		else shogun.y = nil end
		w:As(shogun, function()
			local K = shogun.ns.Shogun
			local lines = K.Build()
			eq(Has(lines, shogun.ns.L.THRONE_LOCATION_LIVE), false, blocked .. " must not advertise an effective position")
			eq(Has(lines, shogun.ns.L.THRONE_LOCATION_PAUSED), true)
			eq(K.SharingLocation(), true, "saved opt-in stays on")
			local live, why = K.EffectiveLocation()
			eq(live, false); eq(why, blocked == "instance" and "instance" or "position")
		end)
		w:Run(6); eq(PositionSends(w), 0, "the actual native timer uses the same gate")
	end
end)

test("Shogun effective map status: valid position resumes automatically, toggle still turns consent off while unavailable", function()
	local w, shogun = Setup()
	assert(shogun.Roles.SetSettings({ live = 1 })); w:Run(0)
	shogun.instance = true
	eq(w:As(shogun, shogun.ns.Shogun.EffectiveLocation), false)
	w:Run(6); eq(PositionSends(w), 0); eq(shogun.Roles.Live(), true, "independent game lives remain enabled")
	shogun.instance = nil
	eq(w:As(shogun, shogun.ns.Shogun.EffectiveLocation), true)
	w:Run(6); eq(PositionSends(w) > 0, true)
	eq(Has(w:As(shogun, shogun.ns.Shogun.Build), shogun.ns.L.THRONE_LOCATION_LIVE), true)
	shogun.noPosition = true
	w:As(shogun, shogun.ns.Shogun.ToggleLocation)
	eq(shogun.db.throneLocation, false, "toggle operates on configured consent, not temporarily unavailable status")
	eq(shogun.Roles.Live(), true)
	w:As(shogun, shogun.ns.Shogun.ToggleLocation)
	eq(shogun.db.throneLocation, true); eq(w:As(shogun, shogun.ns.Shogun.EffectiveLocation), false)
	eq(shogun.Roles.Live(), true, "none of these map decisions toggle game lives")
end)

test("Shogun effective map status: unavailable map, invalid coordinates and lost real Shogun permission fail closed without mutating opt-in", function()
	local w, shogun = Setup()
	for _, coords in ipairs({ { -0.1, 0.3 }, { 0.2, 1.1 }, { 0 / 0, 0.3 }, { 0.4, math.huge } }) do
		shogun.x, shogun.y = coords[1], coords[2]
		eq(w:As(shogun, shogun.ns.Shogun.EffectiveLocation), false)
	end
	shogun.mapID = nil; eq(w:As(shogun, shogun.ns.Shogun.EffectiveLocation), false)
	shogun.mapID, shogun.x, shogun.y = 1453, 0.5, 0.5
	shogun.rank = 1
	local live, why = w:As(shogun, shogun.ns.Shogun.EffectiveLocation)
	eq(live, false); eq(why, "role"); eq(shogun.db.throneLocation, true)
	w:Run(6); eq(PositionSends(w), 0, "a configured preference grants no lost Shogun permission")
end)
