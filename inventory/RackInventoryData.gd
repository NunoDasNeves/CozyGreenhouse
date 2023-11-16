extends InventoryData
class_name RackInventoryData

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data and slot_data.quantity > 0:
		var ret_slot_data: SlotData = SlotData.new()
		ret_slot_data.item_data = slot_data.item_data
		ret_slot_data.quantity = slot_data.quantity
		slot_data.quantity = 0
		inventory_updated.emit(index, slot_data)
		return ret_slot_data
	else:
		return null

func goes_on_rack(item_data: ItemData) -> bool:
	if not item_data:
		return false
	if item_data.has_any_component(["Seed", "Pot", "Fertilizer", "WateringCan"]):
		return true
	return false

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var grabbed_item_data := grabbed_slot_data.item_data

	if not goes_on_rack(grabbed_item_data):
		return grabbed_slot_data

	for i in slot_datas.size():
		var slot_data: SlotData = slot_datas[i]
		if slot_data and slot_data.item_data == grabbed_item_data:
			slot_data.quantity += grabbed_slot_data.quantity
			inventory_updated.emit(i, slot_data)
			return null

	return grabbed_slot_data
