extends Node
## AUTOLOAD "Events" - barramento de sinais global.
## Quem emite (Chest, Player) não precisa conhecer quem escuta (DialogueBox, HUD).
## Também guarda quem está "travando" o input do jogador (diálogo, inventário aberto).

signal dialogue_requested(speaker: String, lines: Array[String])
signal dialogue_finished
signal toast_requested(text: String)
signal prompt_changed(text: String)   # "" = esconder o aviso "[E] ..."

var _input_blockers: Array[Object] = []

## true enquanto algum menu/diálogo estiver aberto: o Player não anda nem interage.
var input_blocked: bool:
	get:
		return not _input_blockers.is_empty()


func block_input(who: Object) -> void:
	if who not in _input_blockers:
		_input_blockers.append(who)


func unblock_input(who: Object) -> void:
	_input_blockers.erase(who)
