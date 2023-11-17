extends InventoryData
class_name RackInventoryData

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data and slot_data.quantity > 0:
		var ret_slot_data: SlotData = SlotData.new()
		ret_slot_data.item_data = slot_data.item_data
		ret_slot_data.quantity = slot_data.quantity
		slot_data.quantity = 0
		slot_updated.emit(index)
		return ret_slot_data
	else:
		return null

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var grabbed_item_data := grabbed_slot_data.item_data

	if not is_home_to_item(grabbed_item_data):
		return grabbed_slot_data

	for i in slot_datas.size():
		var slot_data: SlotData = slot_datas[i]
		if slot_data and slot_data.item_data == grabbed_item_data:
			slot_data.quantity += grabbed_slot_data.quantity
			slot_updated.emit(i)
			return null

	for i in slot_datas.size():
		var slot_data: SlotData = slot_datas[i]
		if not slot_data:
			slot_datas[i] = grabbed_slot_data
			slot_updated.emit(i)
			return null

	slot_datas.push_back(grabbed_slot_data)
	slot_appended.emit(grabbed_slot_data)

	return null
