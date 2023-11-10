extends Node2D
class_name ProductItemScene

@onready var sprite_2d: Sprite2D = $Sprite

func set_item_data(item_data: ItemData) -> void:
	var product_data := item_data as ProductItemData
	assert(product_data)
	sprite_2d.texture = product_data.product_item_texture
