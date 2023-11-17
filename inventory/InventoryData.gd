extends Resource
class_name InventoryData

signal slot_updated(index: int)

@export var slot_datas: Array[SlotData]

func next_day() -> void:
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
		slot_updated.emit(index)
		return slot_data
	else:
		return null

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	slot_datas[index] = grabbed_slot_data
	slot_updated.emit(index)
	if slot_data:
		return slot_data
	else:
		return null
