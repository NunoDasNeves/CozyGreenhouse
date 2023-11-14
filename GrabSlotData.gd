extends Resource
class_name GrabSlotData

var slot_data: SlotData
var from_inventory_data: InventoryData
var from_inventory_index: int

func inventory_interact(inv_data: InventoryData, inv_index: int, action: Slot.Action) -> bool:
	var old_slot_data: SlotData = slot_data
	# ignore rmb if holding something - we should drop it. handle in physics process
	if action == Slot.Action.RightClick:
		if slot_data:
			return false

	slot_data = inv_data.slot_interact(slot_data, inv_index, action)

	if slot_data != old_slot_data:
		from_inventory_data = inv_data
		from_inventory_index = inv_index

	return slot_data != old_slot_data

func dismiss() -> bool:
	if slot_data:
		var old_slot_data = slot_data
		slot_data = from_inventory_data.drop_slot_data(slot_data, from_inventory_index)
		if not slot_data:
			from_inventory_data = null
		return true
	return false
