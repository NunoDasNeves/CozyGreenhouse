extends InventoryData
class_name ShelfInventoryData

func next_day() -> void:
	for i in slot_datas.size():
		var slot_data: SlotData = slot_datas[i]
		if not slot_data:
			continue
		var plant_data := slot_data.item_data as PlantItemData
		if not plant_data:
			continue
		plant_data.next_day()
		inventory_updated.emit(i, slot_data)

func plant_seed(seed_data: SeedItemData, shelf_slot_index: int) -> bool:
	if not seed_data.plant:
		return false
	var slot_data: SlotData = slot_datas[shelf_slot_index]
	if not slot_data or slot_data.item_data.type != ItemData.Type.POT:
		return false
	var plant_item_data: PlantItemData = PlantItemData.create_from_seed(seed_data, slot_data.item_data as RackItemData)
	slot_data.item_data = plant_item_data
	slot_data.quantity = 1
	return true

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(index, null)
		return slot_data
	else:
		return null

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data: SlotData = slot_datas[index]
	var ret: SlotData = grabbed_slot_data

	match (grabbed_slot_data.item_data.type):
		ItemData.Type.SEED:
			if slot_data and slot_data.item_data.type == ItemData.Type.POT:
				if plant_seed(grabbed_slot_data.item_data as SeedItemData, index):
					ret = null
					inventory_updated.emit(index, slot_datas[index])
		ItemData.Type.POT, ItemData.Type.PLANT:
			slot_datas[index] = grabbed_slot_data
			inventory_updated.emit(index, slot_datas[index])
			ret = slot_data
		ItemData.Type.TOOL:
			if slot_data and slot_data.item_data.type == ItemData.Type.PLANT:
				var plant_data := slot_data.item_data as PlantItemData
				var tool_data := grabbed_slot_data.item_data as ToolItemData
				match (tool_data.tool_type):
					ToolItemData.ToolType.WateringCan:
						var water_space: float = plant_data.water.max_val - plant_data.water.curr_val
						var water_to_try_use: float = minf(water_space, 0.5)
						var water_to_use: float = Global.state.try_use_water(water_to_try_use)
						plant_data.water.curr_val += water_to_use
						water_tank_level_updated.emit()
						inventory_updated.emit(index, slot_datas[index])

	return ret
