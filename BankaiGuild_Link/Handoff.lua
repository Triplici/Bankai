local _, own = ...

-- Bankai Guild Link, Bankai Guild's load-on-demand module (1.4.0): its first file. An addon's private table is
-- not shared, so Bankai Guild hands its namespace over for one synchronous call: its LinkLoader.lua sets
-- BankaiGuildLinkHandoff, calls C_AddOns.LoadAddOn("BankaiGuild_Link") once its saved variables are read
-- (INIT, before the login) and clears it. This file takes it at once and clears it too. Every other
-- file of the module starts with
--   local _, own = ...; local ns = own.host; if not ns then return end
-- so the module loaded any other way (another addon's LoadAddOn, "load always" set by the player)
-- finds no host and does nothing; Bankai Guild's loader then reports "nohost".
own.host, BankaiGuildLinkHandoff = BankaiGuildLinkHandoff, nil
local ns = own.host
-- The host interface this module is made for (ns.LinkLoader.HOST_API): another one, or no loader
-- at all, and nothing of the module runs.
own.HOST_API = 1
if type(ns) ~= "table" or type(ns.LinkLoader) ~= "table" or ns.LinkLoader.HOST_API ~= own.HOST_API then
	own.host = nil
	return
end
