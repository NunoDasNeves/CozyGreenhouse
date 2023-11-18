extends AcquireComponent
class_name WaterJugComponent

@export var water_amount: float = 3

func acquire(slot_data: SlotData) -> void:
	assert(slot_data.item_data.has_component("Acquire"))
	var amount: float = slot_data.quantity * water_amount
	Global.state.add_water(amount)
