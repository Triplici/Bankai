local ADDON, own = ...

-- Bankai Guild Arena, the Blood Arena's load-on-demand module (1.2, the design). An addon's private
-- table is not shared, so Bankai Guild hands its namespace over for one synchronous call: Arena.LoadUI
-- sets BankaiGuildArenaHandoff, calls C_AddOns.LoadAddOn and clears it. This file takes it at once.
-- Every other file of the Bankai Guild Arena module starts with
--   local _, own = ...; local ns = own.host; if not ns then return end
-- so the module loaded any other way (another addon's LoadAddOn, "load always" set by the player)
-- finds no host and does nothing; Arena.LoadUI then says to /reload.
own.host, BankaiGuildArenaHandoff = BankaiGuildArenaHandoff, nil
local ns = own.host
if type(ns) ~= "table" or type(ns.Arena) ~= "table" then
	own.host = nil
	return
end
local Arena = ns.Arena

-- The Bankai Guild Arena module's version is Bankai Guild's (the base version, a test build's too: package.sh --test
-- edits only BankaiGuild.toc). Another one means files from two installs: nothing loads, and Bankai Guild
-- says to restart the game.
local mine = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(ADDON, "Version")
if mine ~= ns.VERSION then
	Arena.companionRefused = "version"
	own.host = nil
	return
end
own.VERSION = mine

-- The screens' shared table (Panes.lua fills it; the core reaches it as Arena.ui).
own.ArenaUI = own.ArenaUI or {}
Arena.ui = own.ArenaUI

-- Its saved variables (BankaiGuildArenaDB, the heavy tables: the design) are the game's once the files
-- have run: handed to Arena.Heavy at this addon's ADDON_LOADED.
ns.RegisterEvent("ADDON_LOADED", function(name)
	if name ~= ADDON then return end
	if type(BankaiGuildArenaDB) ~= "table" then BankaiGuildArenaDB = {} end
	Arena.AttachHeavy(BankaiGuildArenaDB)
end)

Arena.companionReady = true
