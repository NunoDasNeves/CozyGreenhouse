extends InventoryData
class_name PotInventoryData

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data and slot_data.quantity > 0:
		slot_data.quantity -= 1
		inventory_updated.emit(self)
		var ret_slot_data: SlotData = SlotData.new()
		ret_slot_data.item_data = slot_data.item_data
		ret_slot_data.quantity = 1
		return ret_slot_data
	else:
		return null

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var grabbed_shelf_item_data := grabbed_slot_data.item_data as ShelfItemData
	if not grabbed_shelf_item_data:
		return grabbed_slot_data

	for slot_data in slot_datas:
		if slot_data.item_data == grabbed_shelf_item_data:
			slot_data.quantity += 1
			break
	inventory_updated.emit(self)

	return null
