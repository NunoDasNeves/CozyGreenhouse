extends InventoryData
class_name ShelfInventoryData

signal slot_light_updated(index: int)

const NUM_COLS: int = 4
const NUM_ROWS: int = 3

var light_slot_datas: Array[LightSlotData] = []

func init() -> void:
	for i in slot_datas.size():
		var light_f: float = 1 - (get_row(i) as float / (NUM_ROWS - 1) )
		var light_slot_data: LightSlotData = LightSlotData.new()
		light_slot_data.base_light = light_f
		light_slot_data.final_light = light_f
		light_slot_datas.push_back(light_slot_data)
	light_slot_datas[9].final_light = 0.5
	light_slot_datas[10].final_light = 1
	light_slot_datas[10].item_data = ItemData.new()
	light_slot_datas[11].final_light = 0.5

func get_row(index: int) -> int:
	return index / NUM_COLS

func get_col(index: int) -> int:
	return index % NUM_COLS

# TODO update lights whenever slots are updated. use this:
func update_slot(index: int) -> void:
	slot_updated.emit(index)
	# TODO recompute lights?? or idk
	slot_light_updated.emit(index)

func gather_fruit(index: int) -> void:
	var slot_data: SlotData = slot_datas[index]
	if not slot_data:
		return
	var plant_component: PlantItemComponent = slot_data.item_data.get_component("Plant")
	if not plant_component:
		return
	var plant_data: PlantData = plant_component.plant
	plant_data.gather_fruit()
	slot_updated.emit(index)

func next_day() -> void:
	for i in slot_datas.size():
		var slot_data: SlotData = slot_datas[i]
		if not slot_data:
			continue
		var plant_component: PlantItemComponent = slot_data.item_data.get_component("Plant")
		if not plant_component:
			return
		plant_component.plant.next_day()
		slot_updated.emit(i)

func plant_seed(seed_component: SeedComponent, shelf_slot_index: int) -> bool:
	assert(seed_component.plant)
	var slot_data: SlotData = slot_datas[shelf_slot_index]
	if not slot_data or not slot_data.item_data.has_component("Pot"):
		return false
	var plant_item_data: ItemData = seed_component.create_plant_item(slot_data.item_data)
	slot_data.item_data = plant_item_data
	slot_data.quantity = 1

	return true

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data:
		slot_datas[index] = null
		slot_updated.emit(index)
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
				slot_updated.emit(index)
		return ret

	if grabbed_item_data.has_component("WateringCan") and slot_data:
		var plant_component: PlantItemComponent = slot_data.item_data.get_component("Plant")
		if plant_component:
			var plant_data: PlantData = plant_component.plant
			var water_space: float = plant_data.water.max_val - plant_data.water.curr_val
			var water_to_try_use: float = minf(water_space, State.WATERING_CAN_WATER_AMOUNT)
			var water_to_use: float = Global.state.try_use_water(water_to_try_use)
			plant_data.water.curr_val += water_to_use
			slot_updated.emit(index)
		return ret

	if grabbed_item_data.has_component("Fertilizer") and slot_data:
		var plant_component: PlantItemComponent = slot_data.item_data.get_component("Plant")
		if plant_component:
			var plant_data: PlantData = plant_component.plant
			var fert_space: float = plant_data.fertilizer.max_val - plant_data.fertilizer.curr_val
			if fert_space >= State.FERTILIZER_AMOUNT:
				plant_data.fertilizer.curr_val += State.FERTILIZER_AMOUNT
				slot_updated.emit(index)
				if grabbed_slot_data.quantity == 1:
					ret = null
				else:
					grabbed_slot_data.quantity -= 1
		return ret

	if grabbed_item_data.has_component("Stackable"):
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
		slot_updated.emit(index)
		return ret
	else:
		slot_datas[index] = grabbed_slot_data
		slot_updated.emit(index)
		ret = slot_data

	return ret
