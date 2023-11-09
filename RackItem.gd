extends Node2D
class_name RackItem

@onready var sprite_2d: Sprite2D = $Sprite

func set_item_data(item_data: ItemData) -> void:
	var rack_data := item_data as RackItemData
	assert(rack_data)
	sprite_2d.texture = rack_data.rack_item_texture
