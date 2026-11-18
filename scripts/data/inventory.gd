class_name Inventory
extends Resource
## MECÂNICA 3 (dados) - o inventário é um Resource com uma lista de Items e um limite.
## Não sabe desenhar nada: a InventoryUI escuta o sinal items_changed e se redesenha.

signal items_changed

@export var max_slots := 8
@export var items: Array[Item] = []


func is_full() -> bool:
	return items.size() >= max_slots


func add(item: Item) -> bool:
	if item == null or is_full():
		return false
	items.append(item)
	items_changed.emit()
	return true


func remove(item: Item) -> bool:
	var index := items.find(item)
	if index == -1:
		return false
	items.remove_at(index)
	items_changed.emit()
	return true
