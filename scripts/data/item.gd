class_name Item
extends Resource
## Dados de um item. É um Resource: cada item vira um arquivo .tres em res://items/
## e pode ser criado/editado só pelo Inspector, sem escrever código.

@export var item_name := ""
@export_multiline var description := ""
@export var icon: Texture2D
