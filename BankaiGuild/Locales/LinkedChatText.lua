local ADDON, ns = ...
local L = ns.L

-- 11-05, linked chat (LinkedChat.lua: Twee's Guild Link, ported). English, then pt-BR; the other
-- languages fall back to English. Every pt-BR line keeps the English line's format codes in order.
L.GLINK_GUILD = "Guild"
L.SETTINGS_GLINK = "Linked guild chat (your /g and /o reach every allied guild)"
L.GLINK_OFFICER = "Officer"
L.GLINK_ON = "Linked chat: on. Your /g and /o reach every allied guild, and theirs show in your guild and officer chat."
L.GLINK_OFF = "Linked chat: off (/bk glink on turns it on)."
L.GLINK_STANDS_DOWN = "Linked chat: the Guild Link addon is installed, so it links the chat and Bankai Guild leaves it alone. Remove one of them."
L.GLINK_NO_GUILD = "You are not in a guild."
L.GLINK_NO_LINE = "No GLink line in Guild Info yet. An officer adds one: GLink:<channel>:<password>:<TAG> (the same channel and password in every allied guild, each guild its own TAG; the password may be left out)."
L.GLINK_CHANNEL = "Guild chat as [%s] on the channel '%s': %s."
L.GLINK_OFFICERS = "Officer chat on '%s': %s."
L.GLINK_IN = "joined"
L.GLINK_NOT_IN = "not joined yet (/bk glink rejoin)"
L.GLINK_LAST = "Last line from another guild: %d s ago."
L.GLINK_LAST_NEVER = "No line from another guild yet this session."
L.GLINK_HELP = "  /bk glink [on|off|rejoin|showchan] - the linked guild chat: its state, on or off, join again, show its raw channel"
L.CHAT_LINKED_INSTEAD = "Bankai Guild's chat is your guild chat now: /g reaches every allied guild, /o every guild's officers (/bk glink)."

if GetLocale and GetLocale() == "ptBR" then
	L.GLINK_GUILD = "Guilda"
	L.SETTINGS_GLINK = "Chat de guilda ligado (seu /g e /o chegam a todas as guildas aliadas)"
	L.GLINK_OFFICER = "Oficial"
	L.GLINK_ON = "Chat ligado entre guildas: ligado. Seu /g e /o chegam a todas as guildas aliadas, e os delas aparecem no seu chat de guilda e de oficiais."
	L.GLINK_OFF = "Chat ligado entre guildas: desligado (/bk glink on liga)."
	L.GLINK_STANDS_DOWN = "Chat ligado entre guildas: o addon Guild Link está instalado, então ele liga o chat e o Bankai Guild não mexe. Remova um dos dois."
	L.GLINK_NO_GUILD = "Você não está em uma guilda."
	L.GLINK_NO_LINE = "Ainda não há linha GLink nas Informações da Guilda. Um oficial adiciona: GLink:<canal>:<senha>:<TAG> (o mesmo canal e senha em todas as guildas aliadas, cada guilda com sua TAG; a senha é opcional)."
	L.GLINK_CHANNEL = "Chat da guilda como [%s] no canal '%s': %s."
	L.GLINK_OFFICERS = "Chat dos oficiais em '%s': %s."
	L.GLINK_IN = "conectado"
	L.GLINK_NOT_IN = "ainda não conectado (/bk glink rejoin)"
	L.GLINK_LAST = "Última linha de outra guilda: há %d s."
	L.GLINK_LAST_NEVER = "Nenhuma linha de outra guilda nesta sessão ainda."
	L.GLINK_HELP = "  /bk glink [on|off|rejoin|showchan] - o chat ligado entre guildas: estado, ligar ou desligar, entrar de novo, mostrar o canal cru"
	L.CHAT_LINKED_INSTEAD = "O chat do Bankai Guild agora é o seu chat de guilda: /g chega a todas as guildas aliadas, /o aos oficiais de todas (/bk glink)."
end
