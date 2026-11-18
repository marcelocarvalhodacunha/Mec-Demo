class_name HUD
extends CanvasLayer
## Textos fixos na tela: ajuda de teclas, aviso "[E] ..." e aviso temporário (toast).
## Tudo chega pelo barramento Events; ninguém precisa chamar o HUD diretamente.

var _toast_tween: Tween

@onready var _prompt: Label = %PromptLabel
@onready var _toast: Label = %ToastLabel


func _ready() -> void:
    Events.prompt_changed.connect(_on_prompt_changed)
    Events.toast_requested.connect(show_toast)


func _on_prompt_changed(text: String) -> void:
    _prompt.text = text
    _prompt.visible = text != ""


func show_toast(text: String) -> void:
    _toast.text = text
    _toast.modulate.a = 1.0
    if _toast_tween:
        _toast_tween.kill()
    _toast_tween = create_tween()
    _toast_tween.tween_interval(2.5)
    _toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.6)
