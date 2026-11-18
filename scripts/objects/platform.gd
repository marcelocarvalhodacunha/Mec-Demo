@tool
class_name Platform
extends StaticBody2D
## Plataforma/chão com tamanho ajustável. Mude "size" no Inspector (ou arraste no
## editor) e o visual (NinePatchRect) e a colisão se ajustam sozinhos.
## A origem do nó é o canto SUPERIOR ESQUERDO, então position = onde fica a grama.

const COLLISION_TRIM := 4.0   # as raízes pendentes embaixo do tile não colidem

@export var size := Vector2(64, 16):
    set(value):
        size = Vector2(maxf(value.x, 12.0), maxf(value.y, 12.0))
        _apply_size()

@onready var _visual: NinePatchRect = $Visual
@onready var _collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
    _apply_size()


func _apply_size() -> void:
    if not is_node_ready():
        return
    _visual.size = size
    var shape := RectangleShape2D.new()   # um shape novo por instância (não compartilhado)
    shape.size = Vector2(size.x, size.y - COLLISION_TRIM)
    _collision.shape = shape
    _collision.position = shape.size / 2.0
