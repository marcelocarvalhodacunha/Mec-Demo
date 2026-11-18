extends Node2D
## "Diretor" da demo: só liga as peças entre si. A lógica fica em cada peça.
## Fluxo: E no baú -> Events.dialogue_requested -> DialogueBox (ENTER avança)
##        -> Player.inventory.add() -> TAB abre a InventoryUI.

@onready var level: Level = $Level
@onready var player: Player = $Player
@onready var inventory_ui: InventoryUI = $UI/InventoryUI


func _ready() -> void:
	player.spawn_at(level.spawn_point.global_position)
	player.set_camera_limits(level.bounds)     # mecânica 1: limites vêm da fase
	inventory_ui.setup(player.inventory)       # mecânica 3: a tela observa os dados
