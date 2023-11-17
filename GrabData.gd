extends Resource
class_name GrabData

var slot_data: SlotData
var from_inventory_data: InventoryData
var from_inventory_index: int

func inventory_interact(inv_data: InventoryData, inv_index: int, action: Slot.Action) -> bool:
	var old_quantity: int = slot_data.quantity if slot_data else 0
	var old_slot_data: SlotData = slot_data
	# ignore rmb if holding something - we should drop it. handle in physics process
	if action == Slot.Action.RightClick:
		if slot_data:
			return false

	slot_data = inv_data.slot_interact(slot_data, inv_index, action)

	if slot_data != old_slot_data:
		from_inventory_data = inv_data
		from_inventory_index = inv_index

	return slot_data != old_slot_data or (slot_data and slot_data.quantity != old_quantity)

func clear() -> void:
	slot_data = null
	from_inventory_data = null

func dismiss() -> bool:
	if slot_data:
		var old_slot_data = slot_data
		slot_data = from_inventory_data.drop_slot_data(slot_data, from_inventory_index)
		if not slot_data:
			from_inventory_data = null
		return true
	return false
