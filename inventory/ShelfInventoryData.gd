extends InventoryData
class_name ShelfInventoryData

var plant_list = preload("res://item/plants/PlantList.tres")

func plant_seed(seed_data: SeedItemData, shelf_slot_index: int) -> bool:
	if not seed_data.plant:
		return false
	var slot_data: SlotData = slot_datas[shelf_slot_index]
	if not slot_data or slot_data.item_data.type != ItemData.Type.POT:
		return false
	var plant_item_data: PlantItemData = seed_data.plant.duplicate()
	plant_item_data.pot_item_data = slot_data.item_data
	slot_data.item_data = plant_item_data
	return true

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	var ret: SlotData = grabbed_slot_data

	match (grabbed_slot_data.item_data.type):
		ItemData.Type.SEED:
			if slot_data and slot_data.item_data.type == ItemData.Type.POT:
				if plant_seed(grabbed_slot_data.item_data as SeedItemData, index):
					ret = null
		ItemData.Type.POT:
			slot_datas[index] = grabbed_slot_data
			ret = slot_data

	inventory_updated.emit(self)
	return ret
