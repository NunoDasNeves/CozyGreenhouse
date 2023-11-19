extends FruitComponent
class_name WaterFruitComponent

@export var water_amount: float = 3

func gather(parent: ItemData) -> void:
	Global.state.add_water(water_amount)
