extends Resource
class_name ItemData

enum Type {
	NONE,
	SEED,
	POT,
	PLANT,
}

@export var name: String = ""
@export_multiline var description: String = ""
@export var scene: PackedScene
@export var type: Type

func add_scene_to(parent: Node2D) -> Node2D:
	var node := scene.instantiate() as Node2D
	parent.add_child(node)
	return node

