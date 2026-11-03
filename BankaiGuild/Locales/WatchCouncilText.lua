local ADDON, ns = ...
local L = ns.L
-- 1.2.1: the High Council's own sections in The Watch (Watch.lua: its reports and cases, apart from
-- any guild's), and what the Shogun's client keeps of a council report.
L.WATCH_CASES_TITLE_COUNCIL = "Cases of the High Council"
L.WATCH_COUNCIL_TIP = "Reports from members of every Bankai Guild guild, taken and passed on by the Shogun's client: only from a reporter it already knows in the guild he names, and only with the lines it heard itself in the Bankai Guild channel. The Shogun and the High Council act on them in Bankai Guild's chats, never with a guild's Watch. A report proves nothing by itself."
L.WATCH_REPORT_LINES_COUNCIL = "%d of the %d lines it named, each one the Shogun's client heard itself in the Bankai Guild channel (any other was left out)."
L.WATCH_COUNCIL_DETAIL = "The High Council's reports and cases: from members of every Bankai Guild guild, through the Shogun's client. Nothing here is a sanction until the Shogun or a councillor chooses one in Bankai Guild's chats."
if GetLocale and GetLocale() == "ptBR" then
	L.WATCH_CASES_TITLE_COUNCIL = "Casos do High Council"
	L.WATCH_COUNCIL_TIP = "Denúncias de membros de todas as guildas do Bankai Guild, recebidas e repassadas pelo cliente do Shogun: só de quem ele já conhece na guilda que diz, e só com as linhas que ele mesmo ouviu no canal do Bankai Guild. O Shogun e o High Council agem nelas nos chats do Bankai Guild, nunca com a Watch de uma guilda. Uma denúncia sozinha não prova nada."
	L.WATCH_REPORT_LINES_COUNCIL = "%d das %d linhas que ela indicou, cada uma ouvida pelo próprio cliente do Shogun no canal do Bankai Guild (as outras ficaram de fora)."
	L.WATCH_COUNCIL_DETAIL = "As denúncias e os casos do High Council: de membros de todas as guildas do Bankai Guild, pelo cliente do Shogun. Nada aqui é uma sanção até o Shogun ou um conselheiro escolher uma nos chats do Bankai Guild."
end
