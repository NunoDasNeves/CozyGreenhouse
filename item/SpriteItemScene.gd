extends ItemScene
class_name SpriteItemScene

@onready var sprite_2d: Sprite2D = $Sprite

func set_item_data(item_data: ItemData) -> void:
	var texture_component := item_data.get_component("Texture") as TextureComponent
	if texture_component:
		sprite_2d.texture = texture_component.texture
