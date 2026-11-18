class_name InventoryUI
extends CanvasLayer
## MECÂNICA 3 (tela) - grade de slots (Controls) que abre/fecha com TAB.
## Só LÊ o Inventory (Resource); quando ele emite items_changed, redesenha os slots.

@export var slot_scene: PackedScene   ## inventory_slot.tscn

var is_open := false

var _inventory: Inventory

@onready var _root: Control = %Root
@onready var _grid: GridContainer = %Grid


func setup(inventory: Inventory) -> void:
	_inventory = inventory
	for i in inventory.max_slots:
		_grid.add_child(slot_scene.instantiate())   # um slot por espaço
	inventory.items_changed.connect(_refresh)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("toggle_inventory"):
		return
	if is_open:
		_set_open(false)
	elif not Events.input_blocked:      # não abre por cima de um diálogo
		_set_open(true)
	get_viewport().set_input_as_handled()


func _set_open(value: bool) -> void:
	is_open = value
	_root.visible = value
	if value:
		Events.block_input(self)
	else:
		Events.unblock_input(self)


## Redistribui os itens da lista pelos slots.
func _refresh() -> void:
	var slots := _grid.get_children()
	for i in slots.size():
		var slot: InventorySlot = slots[i]
		slot.set_item(_inventory.items[i] if i < _inventory.items.size() else null)
