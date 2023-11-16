extends InventoryData
class_name ShelfInventoryData

func gather_fruit(index: int) -> void:
	var slot_data: SlotData = slot_datas[index]
	if not slot_data:
		return
	var plant_data = slot_data.item_data as PlantItemData
	if not plant_data:
		return
	var products_gathered: Array[ProductItemData] = plant_data.gather_fruit()
	Global.state.add_products_to_sell(products_gathered)
	inventory_updated.emit(index, slot_data)

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

func plant_seed(seed_component: SeedComponent, shelf_slot_index: int) -> bool:
	assert(seed_component.plant)
	var slot_data: SlotData = slot_datas[shelf_slot_index]
	if not slot_data or not slot_data.item_data.has_component("Pot"):
		return false
	var plant_item_data: PlantItemData = PlantItemData.create_from_seed(seed_component, slot_data.item_data)
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
	var grabbed_item_data: ItemData = grabbed_slot_data.item_data

	var seed_component := grabbed_item_data.get_component("Seed") as SeedComponent
	if seed_component:
		if slot_data and slot_data.item_data.has_component("Pot"):
			if plant_seed(seed_component, index):
				grabbed_slot_data.quantity -= 1
				if !grabbed_slot_data.quantity:
					ret = null
				inventory_updated.emit(index, slot_datas[index])
		return ret

	if grabbed_item_data.has_component("Pot"):
		if slot_data and slot_data.item_data == grabbed_item_data:
			grabbed_slot_data.quantity += 1
			slot_datas[index] = null
		elif grabbed_slot_data.quantity == 1:
			slot_datas[index] = grabbed_slot_data
			ret = slot_data
		elif not slot_data:
			slot_datas[index] = grabbed_slot_data.duplicate()
			slot_datas[index].quantity = 1
			grabbed_slot_data.quantity -= 1
			if !grabbed_slot_data.quantity:
				ret = null
		inventory_updated.emit(index, slot_datas[index])

	if grabbed_item_data.has_component("WateringCan") and slot_data:
		var plant_data := slot_data.item_data as PlantItemData
		if plant_data:
			var water_space: float = plant_data.water.max_val - plant_data.water.curr_val
			var water_to_try_use: float = minf(water_space, State.WATERING_CAN_WATER_AMOUNT)
			var water_to_use: float = Global.state.try_use_water(water_to_try_use)
			plant_data.water.curr_val += water_to_use
			water_tank_level_updated.emit()
			inventory_updated.emit(index, slot_datas[index])

	match (grabbed_slot_data.item_data.type_name):
		ItemData.TypeName.PLANT:
			slot_datas[index] = grabbed_slot_data
			inventory_updated.emit(index, slot_datas[index])
			ret = slot_data

	return ret
