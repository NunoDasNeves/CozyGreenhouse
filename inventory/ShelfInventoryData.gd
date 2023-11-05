extends InventoryData
class_name ShelfInventoryData

func on_slot_clicked(index: int, button: int) -> void:
	inventory_interact.emit(self, index, button)

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	# TODO
	return grabbed_slot_data
	
	var grabbed_shelf_item_data := grabbed_slot_data.item_data as ShelfItemData
	if not grabbed_shelf_item_data:
		return grabbed_slot_data

	var grabbed_seed_item_data := grabbed_slot_data.item_data as SeedItemData
	if not grabbed_seed_item_data:
		return grabbed_slot_data

	inventory_updated.emit(self)

	return null
