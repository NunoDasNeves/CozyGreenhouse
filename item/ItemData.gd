extends Resource
class_name ItemData

enum Type {
	SEED,
	POT,
	PLANT,
}

@export var name: String = ""
@export_multiline var description: String = ""
@export var texture: Texture
@export var type: Type

func is_stackable() -> bool:
	return false
