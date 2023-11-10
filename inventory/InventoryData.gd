extends Resource
class_name InventoryData

signal inventory_updated(index: int, item_data: ItemData)
signal inventory_interact(inventory_data: InventoryData, index: int, button: int)

@export var slot_datas: Array[SlotData]

func on_slot_clicked(index: int, button: int):
	inventory_interact.emit(self, index, button)

func slot_interact(grabbed_slot_data: SlotData, index: int, button: int) -> SlotData:
	if button != MOUSE_BUTTON_LEFT:
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
