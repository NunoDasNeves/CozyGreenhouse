extends FruitComponent
class_name WaterFruitComponent

const WATER_AMOUNT: float = 1

func gather(parent: ItemData) -> void:
	Global.state.add_water(WATER_AMOUNT)
