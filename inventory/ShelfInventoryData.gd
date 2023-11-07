extends InventoryData
class_name ShelfInventoryData

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null

func plant_seed(seed_data: ItemData, shelf_slot_index: int) -> bool:
	var slot_data := SlotData.new()
	slot_data.item_data = load("res://item/plants/Plant.tres")
	slot_datas[shelf_slot_index] = slot_data
	return true

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	var ret: SlotData = grabbed_slot_data

	match (grabbed_slot_data.item_data.type):
		ItemData.Type.SEED:
			if slot_data and slot_data.item_data.type == ItemData.Type.POT:
				if plant_seed(grabbed_slot_data.item_data, index):
					ret = null
		ItemData.Type.POT:
			slot_datas[index] = grabbed_slot_data
			ret = slot_data

	inventory_updated.emit(self)
	return ret
