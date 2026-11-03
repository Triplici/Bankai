local ADDON, ns = ...
local L = ns.L
L.MAINKEY_ON, L.MAINKEY_OFF = "on", "off"
L.MAINKEY_STATUS = "Bankai Guild shortcut, Shift + your guild key (%s): %s. Used only while that key is unbound; saved bindings are never changed. Your own key: Key Bindings, AddOns, Toggle Bankai Guild. /bk hotkey on|off"
L.MAINKEY_BINDING = "Toggle Bankai Guild"
L.HELP_MAINKEY = "  /bk hotkey on|off - open/close Bankai Guild with Shift + your guild key (Shift-J), only when that key is unbound (mouse and keyboard). Or pick a key in Key Bindings, AddOns, Toggle Bankai Guild."
if GetLocale and GetLocale() == "ptBR" then
	L.MAINKEY_ON, L.MAINKEY_OFF = "ligado", "desligado"
	L.MAINKEY_STATUS = "Atalho do Bankai Guild, Shift + a sua tecla da guilda (%s): %s. Só usado se essa tecla estiver livre; suas teclas salvas não são alteradas. A sua própria tecla: Atalhos do jogo (Key Bindings), AddOns, Abrir/fechar o Bankai Guild. /bk hotkey on|off"
	L.MAINKEY_BINDING = "Abrir/fechar o Bankai Guild"
	L.HELP_MAINKEY = "  /bk hotkey on|off - abre/fecha Bankai Guild com Shift + a sua tecla da guilda (Shift-J), somente se essa tecla estiver livre (mouse e teclado). Ou escolha uma tecla nos Atalhos do jogo (Key Bindings), AddOns, Abrir/fechar o Bankai Guild."
end
