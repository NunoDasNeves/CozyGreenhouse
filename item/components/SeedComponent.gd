extends ItemComponent
class_name SeedComponent

@export var plant: ItemData

static func get_component_name() -> StringName:
	return "Seed"

func create_plant_item(pot_item: ItemData) -> ItemData:
	var old_plant_component: PlantItemComponent = plant.get_component("Plant")
	var plant_item: ItemData = plant.duplicate()

	# duplicating the type is kinda tricky, duplicate(true) doesn't work
	plant_item.type = plant_item.type.duplicate()
	plant_item.type._dict = {}
	plant_item.type.components = []
	for component in plant.type.components:
		# don't want to deep copy the plant data component
		plant_item.type.components.push_back(component.duplicate())

	var plant_component: PlantItemComponent = plant_item.get_component("Plant")
	assert(old_plant_component != plant_component)
	var plant_data: PlantData = plant_component.plant.duplicate()
	plant_component.plant = plant_data
	assert(plant_data == (plant_item.get_component("Plant") as PlantItemComponent).plant)
	plant_data.pot_item_data = pot_item
	# pick which to duplicate; e.g. want the fruit to not be copied
	if plant_data.light:
		plant_data.light = plant_data.light.duplicate()
	if plant_data.water:
		plant_data.water = plant_data.water.duplicate()
	if plant_data.fertilizer:
		plant_data.fertilizer = plant_data.fertilizer.duplicate()

	return plant_item
