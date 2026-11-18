class_name Level
extends Node2D
## Uma fase. Define a área jogável (bounds), o ponto de nascimento e as paredes
## invisíveis nas laterais. Chão, plataformas, baús e fundo são nós filhos da cena.

## Área que a câmera pode mostrar e onde o jogador pode andar (mecânica 1).
@export var bounds := Rect2i(0, 0, 1280, 108)

@onready var spawn_point: Marker2D = $SpawnPoint


func _ready() -> void:
	_build_side_walls()


func _build_side_walls() -> void:
	var walls := StaticBody2D.new()
	walls.name = "SideWalls"
	add_child(walls)
	var center_y := bounds.position.y + bounds.size.y / 2.0
	for x in [bounds.position.x - 8, bounds.end.x + 8]:
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(16, 2000)
		collision.shape = shape
		collision.position = Vector2(x, center_y)
		walls.add_child(collision)
