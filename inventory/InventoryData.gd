extends Resource
class_name InventoryData

signal inventory_updated(index: int, item_data: ItemData)
signal water_tank_level_updated
signal money_updated
signal label_updated(index: int, text: String)
signal button_label_updated(index: int, text: String)
signal button_enable_updated(index: int, enabled: bool)

@export var slot_datas: Array[SlotData]

func next_day() -> void:
	pass

func button_pressed(index: int) -> void:
	pass

func slot_interact(grabbed_slot_data: SlotData, index: int, action: Slot.Action) -> SlotData:
	if action != Slot.Action.Click && action != Slot.Action.Hold:
		return grabbed_slot_data
	if grabbed_slot_data:
		return drop_slot_data(grabbed_slot_data, index)
	else:
		return grab_slot_data(index)

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(index, slot_data)
		return slot_data
	else:
		return null

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	slot_datas[index] = grabbed_slot_data
	inventory_updated.emit(index, slot_data)
	if slot_data:
		return slot_data
	else:
		return null
