extends Resource
class_name InventoryData

signal slot_updated(index: int)
signal slot_appended(slot_data: SlotData)

@export var slot_datas: Array[SlotData]

func init() -> void:
	pass

func next_day() -> void:
	pass

func is_home_to_item(item_data: ItemData) -> bool:
	if not item_data:
		return false

	var home_inv: ItemData.HomeName = item_data.home_inventory
	var home_inventory_data: InventoryData = Global.state.get_home_inventory_data(home_inv)

	return home_inventory_data == self

func slot_interact(grabbed_slot_data: SlotData, index: int, action: Slot.Action) -> SlotData:
	if action != Slot.Action.Click && action != Slot.Action.Hold:
		return grabbed_slot_data
	if grabbed_slot_data:
		return drop_slot_data(grabbed_slot_data, index)
	else:
		return grab_slot_data(index)

func grab_slot_data(index: int) -> SlotData:
	return null

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	return null
