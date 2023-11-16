extends ItemComponent
class_name AcquireComponent

static func get_component_name() -> StringName:
	return "Acquire"

func acquire(slot_data: SlotData) -> void:
	assert(slot_data.item_data.has_component("Acquire"))
	var home_inventory_data: InventoryData = Global.state.get_home_inventory_data(slot_data.item_data.home_inventory)
	if home_inventory_data:
		home_inventory_data.drop_slot_data(slot_data, 0)
