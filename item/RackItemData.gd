extends ItemData
class_name RackItemData

@export var rack_item_texture: Texture2D
@export var show_1x_quantity: bool

func add_scene_to(parent: Node2D) -> Node2D:
	var node := scene.instantiate() as Node2D
	parent.add_child(node)
	var rack_item := node as RackItem
	rack_item.sprite_2d.texture = rack_item_texture
	return node
