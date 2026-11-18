class_name InventorySlot
extends PanelContainer
## Um quadradinho do inventário: ícone + nome.

@onready var _icon: TextureRect = %Icon
@onready var _name_label: Label = %NameLabel


func set_item(item: Item) -> void:
    if item == null:
        _icon.texture = null
        _name_label.text = ""
        tooltip_text = ""
    else:
        _icon.texture = item.icon
        _name_label.text = item.item_name
        tooltip_text = item.description
