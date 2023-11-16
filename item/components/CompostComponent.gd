extends ItemComponent
class_name CompostComponent

@export var base_compost_value: float = 1

static func get_component_name() -> StringName:
	return "Compost"

func get_compost_value(parent: ItemData) -> float:
	if parent:
		var plant_component: PlantItemComponent = parent.get_component("Plant")
		if plant_component:
			var plant_data: PlantData = plant_component.plant
			return base_compost_value + plant_data.get_compost_bonus()
	return base_compost_value
