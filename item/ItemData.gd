extends Resource
class_name ItemData

enum TypeName {
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
@export var type_name: TypeName
@export var type: ItemType

func get_component(component_name: StringName) -> Variant:
	return type.components_dict.get(component_name)
