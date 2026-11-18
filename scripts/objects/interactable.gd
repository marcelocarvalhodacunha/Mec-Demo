class_name Interactable
extends Area2D
## Base de tudo que o jogador aciona com [E] (baú, NPC, alavanca...).
## Quando o Player entra na área, ela se registra em player.interactable.
## Para criar um novo objeto interativo: estenda esta classe e sobrescreva interact().

@export var prompt := "[E] Interagir"


func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)


## Texto mostrado no HUD enquanto o jogador está por perto.
func get_prompt() -> String:
    return prompt


## Sobrescreva nas classes filhas.
func interact(_player: Player) -> void:
    pass


func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        body.interactable = self


func _on_body_exited(body: Node2D) -> void:
    if body is Player and body.interactable == self:
        body.interactable = null
