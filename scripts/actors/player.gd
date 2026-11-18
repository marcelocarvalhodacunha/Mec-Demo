class_name Player
extends CharacterBody2D
## Jogador de plataforma 2D. A Camera2D é FILHA do jogador, por isso o segue sozinha.

@export_group("Movimento")
@export var speed := 100.0
@export var acceleration := 900.0
@export var friction := 1200.0
@export var jump_velocity := -250.0
@export var coyote_time := 0.1        ## tolerância para pular logo após sair da borda
@export var jump_buffer_time := 0.1   ## tolerância para apertar pulo um pouco antes de pousar

@export_group("Inventário")
@export var inventory: Inventory      ## Resource criado em player.tscn (Inspector)

## Interactable ao alcance (preenchido pela própria Interactable; ver interactable.gd).
var interactable: Interactable
var spawn_position := Vector2.ZERO

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _coyote := 0.0
var _jump_buffer := 0.0
var _last_prompt := ""

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D


func _physics_process(delta: float) -> void:
	var blocked := Events.input_blocked
	var direction := 0.0 if blocked else Input.get_axis("move_left", "move_right")

	if not is_on_floor():
		velocity.y += _gravity * delta

	var rate := acceleration if direction != 0.0 else friction
	velocity.x = move_toward(velocity.x, direction * speed, rate * delta)

	_handle_jump(delta, blocked)
	move_and_slide()

	if direction != 0.0:
		sprite.flip_h = direction < 0.0
	_update_animation(direction)
	_update_prompt(blocked)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and interactable and not Events.input_blocked:
		interactable.interact(self)


func _handle_jump(delta: float, blocked: bool) -> void:
	_coyote = coyote_time if is_on_floor() else _coyote - delta
	if not blocked and Input.is_action_just_pressed("jump"):
		_jump_buffer = jump_buffer_time
	else:
		_jump_buffer -= delta

	if _jump_buffer > 0.0 and _coyote > 0.0:
		velocity.y = jump_velocity
		_jump_buffer = 0.0
		_coyote = 0.0
	# soltar o botão cedo = pulo mais curto
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5


func _update_animation(direction: float) -> void:
	var animation := &"idle"
	if not is_on_floor():
		animation = &"jump" if velocity.y < 0.0 else &"fall"
	elif direction != 0.0:
		animation = &"walk"
	if sprite.animation != animation:
		sprite.play(animation)


## Avisa o HUD só quando o texto muda ("[E] Abrir baú" aparece/some).
func _update_prompt(blocked: bool) -> void:
	var text := ""
	if interactable and not blocked:
		text = interactable.get_prompt()
	if text != _last_prompt:
		_last_prompt = text
		Events.prompt_changed.emit(text)


## Chamado pelo Main: define o ponto de nascimento (também usado ao cair no buraco).
func spawn_at(position_in_world: Vector2) -> void:
	spawn_position = position_in_world
	respawn()


func respawn() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	camera.reset_smoothing()


## MECÂNICA 1 - limites da fase: a câmera nunca mostra nada fora desse retângulo.
func set_camera_limits(area: Rect2i) -> void:
	camera.limit_left = area.position.x
	camera.limit_top = area.position.y
	camera.limit_right = area.end.x
	camera.limit_bottom = area.end.y
	camera.reset_smoothing()
