extends AcquireComponent
class_name WaterJugComponent

const WATER_JUG_AMOUNT: float = 1

func acquire(slot_data: SlotData) -> void:
	assert(slot_data.item_data.has_component("Acquire"))
	var amount: float = slot_data.quantity * WATER_JUG_AMOUNT
	Global.state.add_water(amount)
