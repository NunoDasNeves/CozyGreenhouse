extends Resource
class_name PlantList

@export var plant_list: Array[PlantItemData]
var plant_dict: Dictionary

func _init() -> void:
	for plant in plant_list:
		plant_dict[plant.name] = plant
