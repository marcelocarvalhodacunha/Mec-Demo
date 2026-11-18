class_name DialogueBox
extends CanvasLayer
## MECÂNICA 2 - caixa de diálogo (Control) com RichTextLabel e visible_characters.
## Abre quando alguém emite Events.dialogue_requested(speaker, lines).
## ENTER: se o texto ainda está aparecendo, completa na hora; senão, vai
## para a próxima fala. Ao fim da última fala emite Events.dialogue_finished.

const SECONDS_PER_CHAR := 0.035

var is_open := false

var _lines: Array[String] = []
var _index := 0
var _typing := false
var _tween: Tween

@onready var _panel: PanelContainer = %Panel
@onready var _speaker: Label = %SpeakerLabel
@onready var _text: RichTextLabel = %TextLabel
@onready var _hint: Label = %HintLabel


func _ready() -> void:
	Events.dialogue_requested.connect(start)


func start(speaker: String, lines: Array[String]) -> void:
	if is_open or lines.is_empty():
		return
	_lines = lines
	_index = 0
	_speaker.text = speaker
	_speaker.visible = speaker != ""
	is_open = true
	Events.block_input(self)
	_panel.show()
	_show_line()


func _unhandled_input(event: InputEvent) -> void:
	if not is_open or not event.is_action_pressed("advance_dialog"):
		return
	get_viewport().set_input_as_handled()
	if _typing:
		_finish_typing()
	else:
		_next_line()


func _show_line() -> void:
	_text.text = _lines[_index]          # aceita BBCode: [b], [color=yellow]...
	_text.visible_characters = 0         # nenhuma letra visível...
	_typing = true
	_hint.modulate.a = 0.0
	if _tween:
		_tween.kill()
	# ...e o Tween leva até o total de letras. get_total_character_count()
	# ignora as tags BBCode, então só conta o que o jogador realmente vê.
	var total := _text.get_total_character_count()
	_tween = create_tween()
	_tween.tween_property(_text, "visible_characters", total, total * SECONDS_PER_CHAR)
	_tween.finished.connect(_on_typing_done)


func _finish_typing() -> void:
	if _tween:
		_tween.kill()
	_text.visible_characters = -1        # -1 = mostrar tudo
	_on_typing_done()


func _on_typing_done() -> void:
	_typing = false
	_hint.modulate.a = 1.0


func _next_line() -> void:
	_index += 1
	if _index >= _lines.size():
		_close()
	else:
		_show_line()


func _close() -> void:
	_panel.hide()
	is_open = false
	Events.unblock_input(self)
	Events.dialogue_finished.emit()
