extends InventoryData
class_name ShelfInventoryData

signal attach_slot_updated(index: int)
signal light_data_updated(index: int)

const NUM_COLS: int = 4
const NUM_ROWS: int = 3

var light_datas: Array[LightData] = []
var attach_slot_datas: Array[SlotData] = []

func init() -> void:
	for i in slot_datas.size():
		attach_slot_datas.push_back(null)

		var light_f: float = 1 - (get_row(i) as float / (NUM_ROWS - 1) )
		var light_data: LightData = LightData.new()
		light_data.base_light = light_f
		light_data.final_light = light_f
		light_datas.push_back(light_data)

func get_row(index: int) -> int:
	return index / NUM_COLS

func get_col(index: int) -> int:
	return index % NUM_COLS

func update_slot(index: int) -> void:
	var attach_slot_data: SlotData = attach_slot_datas[index]
	light_datas[index].final_light = light_datas[index].base_light
	if attach_slot_data:
		var item_data: ItemData = attach_slot_data.item_data
		if item_data.has_component("UVLight"):
			light_datas[index].final_light = 1

	var slot_data: SlotData = slot_datas[index]
	if slot_data:
		var item_data: ItemData = slot_data.item_data
		var plant_component: PlantItemComponent = item_data.get_component("Plant")
		if plant_component:
			var plant_data: PlantData = plant_component.plant
			if plant_data.light:
				plant_data.light.curr_val = light_datas[index].final_light * plant_data.light.max_val
			elif plant_data.emit_light and plant_data.num_fruits:
				light_datas[index].final_light = 1

	slot_updated.emit(index)
	light_data_updated.emit(index)
	attach_slot_updated.emit(index)

func gather_fruit(index: int) -> void:
	var slot_data: SlotData = slot_datas[index]
	if not slot_data:
		return
	var plant_component: PlantItemComponent = slot_data.item_data.get_component("Plant")
	if not plant_component:
		return
	var plant_data: PlantData = plant_component.plant
	plant_data.gather_fruit()
	Global.play_click_sound()

	if plant_data.plant_is_fruit:
		slot_data.item_data = plant_data.pot_item_data

	update_slot(index)

func next_day() -> void:
	for i in slot_datas.size():
		var slot_data: SlotData = slot_datas[i]
		if not slot_data:
			continue
		var plant_component: PlantItemComponent = slot_data.item_data.get_component("Plant")
		if not plant_component:
			continue
		plant_component.plant.next_day()
		update_slot(i)

func plant_seed(seed_component: SeedComponent, shelf_slot_index: int) -> bool:
	assert(seed_component.plant)
	var slot_data: SlotData = slot_datas[shelf_slot_index]
	if not slot_data or not slot_data.item_data.has_component("Pot"):
		return false
	var plant_item_data: ItemData = seed_component.create_plant_item(slot_data.item_data)
	slot_data.item_data = plant_item_data
	slot_data.quantity = 1

	return true

func slot_interact(grabbed_slot_data: SlotData, index: int, action: Slot.Action) -> SlotData:
	match action:
		Slot.Action.Click, Slot.Action.Hold:
			if grabbed_slot_data:
				return drop_slot_data(grabbed_slot_data, index)
			else:
				return grab_slot_data(index)
		Slot.Action.AttachClick:
			if grabbed_slot_data:
				return drop_attach_slot_data(grabbed_slot_data, index)
			else:
				return grab_attach_slot_data(index)
	return grabbed_slot_data

func _grab_slot_data(index: int, the_slot_datas: Array[SlotData]) -> SlotData:
	var slot_data = the_slot_datas[index]
	if slot_data:
		the_slot_datas[index] = null
		update_slot(index)
		return slot_data
	else:
		return null

func grab_attach_slot_data(index: int) -> SlotData:
	return _grab_slot_data(index, attach_slot_datas)

func grab_slot_data(index: int) -> SlotData:
	return _grab_slot_data(index, slot_datas)

func _drop_slot_data(grabbed_slot_data: SlotData, index: int, the_slot_datas: Array) -> SlotData:
	var slot_data: SlotData = the_slot_datas[index]
	var ret: SlotData = grabbed_slot_data
	var grabbed_item_data: ItemData = grabbed_slot_data.item_data

	if grabbed_item_data.has_component("Stackable"):
		if slot_data and slot_data.item_data == grabbed_item_data:
			grabbed_slot_data.quantity += 1
			the_slot_datas[index] = null
		elif grabbed_slot_data.quantity == 1:
			the_slot_datas[index] = grabbed_slot_data
			ret = slot_data
		elif not slot_data:
			the_slot_datas[index] = grabbed_slot_data.duplicate()
			the_slot_datas[index].quantity = 1
			grabbed_slot_data.quantity -= 1
			if !grabbed_slot_data.quantity:
				ret = null
	else:
		the_slot_datas[index] = grabbed_slot_data
		ret = slot_data

	update_slot(index)

	return ret

func drop_attach_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var grabbed_item_data: ItemData = grabbed_slot_data.item_data
	if grabbed_item_data.has_component("Attach"):
		return _drop_slot_data(grabbed_slot_data, index, attach_slot_datas)
	return grabbed_slot_data

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data: SlotData = slot_datas[index]
	var ret: SlotData = grabbed_slot_data
	var grabbed_item_data: ItemData = grabbed_slot_data.item_data

	var seed_component := grabbed_item_data.get_component("Seed") as SeedComponent
	if seed_component:
		if plant_seed(seed_component, index):
			grabbed_slot_data.quantity -= 1
			if !grabbed_slot_data.quantity:
				ret = null
			update_slot(index)
		return ret

	if grabbed_item_data.has_component("WateringCan"):
		if not slot_data:
			return ret
		var plant_component: PlantItemComponent = slot_data.item_data.get_component("Plant")
		if plant_component:
			var plant_data: PlantData = plant_component.plant
			if plant_data.water:
				var water_space: float = plant_data.water.max_val - plant_data.water.curr_val
				var water_to_try_use: float = minf(water_space, State.WATERING_CAN_WATER_AMOUNT)
				var water_to_use: float = Global.state.try_use_water(water_to_try_use)
				plant_data.water.curr_val += water_to_use
				update_slot(index)
		return ret

	if grabbed_item_data.has_component("Fertilizer"):
		if not slot_data:
			return ret
		var plant_component: PlantItemComponent = slot_data.item_data.get_component("Plant")
		if plant_component:
			var plant_data: PlantData = plant_component.plant
			if plant_data.fertilizer:
				var fert_space: float = plant_data.fertilizer.max_val - plant_data.fertilizer.curr_val
				if fert_space >= 1:
					plant_data.fertilizer.curr_val = plant_data.fertilizer.happy_max
					update_slot(index)
					if grabbed_slot_data.quantity == 1:
						ret = null
					else:
						grabbed_slot_data.quantity -= 1
		return ret

	if grabbed_item_data.has_component("Attach"):
		return _drop_slot_data(grabbed_slot_data, index, attach_slot_datas)

	return _drop_slot_data(grabbed_slot_data, index, slot_datas)


