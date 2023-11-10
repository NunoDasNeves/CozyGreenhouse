extends Resource
class_name ItemData

enum Type {
	NONE,
	SEED,
	POT,
	PLANT,
	TOOL,
	FRUIT,
}

@export var name: String = ""
@export_multiline var description: String = ""
@export var scene: PackedScene
@export var type: Type
