extends ItemComponent
class_name FruitComponent

static func get_component_name() -> StringName:
	return "Fruit"

func gather(parent: ItemData) -> void:
	Global.state.add_item_to_sell(parent)
