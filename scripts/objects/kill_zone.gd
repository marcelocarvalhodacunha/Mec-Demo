class_name KillZone
extends Area2D
## Área de "queda no buraco": quem for o Player volta ao ponto de nascimento.


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        body.respawn.call_deferred()   # deferred: não mexer na física durante o sinal
