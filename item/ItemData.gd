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

enum HomeName {
	Seed,
	Pot,
	Tool,
	Shelf,
	Sell,
	Buy,
}

@export var name: String = ""
@export_multiline var description: String = ""
@export var scene: PackedScene
@export var type_name: TypeName
@export var home_inventory: HomeName
@export var type: ItemType

func get_component(component_name: StringName) -> Variant:
	if not type:
		return null
	return type.components_dict.get(component_name)

func has_component(component_name: StringName) -> bool:
	if not type:
		return false
	return type.components_dict.has(component_name)

func has_any_component(component_names: Array[StringName]) -> bool:
	if not type:
		return false
	for component in component_names:
		if type.components_dict.has(component):
			return true
	return false
