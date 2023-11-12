extends ItemScene
class_name ProductItemScene

@export var sprite_2d: Sprite2D

func set_item_data(item_data: ItemData) -> void:
	var product_data := item_data as ProductItemData
	assert(product_data)
	sprite_2d.texture = product_data.product_item_texture
