class_name Chest
extends Interactable
## Baú: fala, entrega um Item (Resource) ao inventário do jogador e fica aberto.
## Tudo é configurado no Inspector de cada instância na fase - o script não tem texto fixo.

@export var speaker := "Baú"
@export var lines: Array[String] = []                        ## falas da primeira abertura
@export var empty_lines: Array[String] = ["O baú está vazio."]
@export var item: Item                                       ## arquivo .tres em res://items/
@export var closed_prompt := "[E] Abrir baú"
@export var opened_prompt := "[E] Examinar baú"

var opened := false:
	set(value):
		opened = value
		if is_node_ready():
			_sprite.play(&"open" if opened else &"closed")

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func get_prompt() -> String:
	return opened_prompt if opened else closed_prompt


func interact(player: Player) -> void:
	if opened:
		Events.dialogue_requested.emit(speaker, empty_lines)
		return
	if player.inventory.is_full():
		Events.toast_requested.emit("Inventário cheio!")
		return

	opened = true
	if not lines.is_empty():
		Events.dialogue_requested.emit(speaker, lines)
		await Events.dialogue_finished          # espera o último ENTER fechar a caixa
	if player.inventory.add(item):
		Events.toast_requested.emit("Você pegou: %s  (TAB abre o inventário)" % item.item_name)
