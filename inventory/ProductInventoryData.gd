extends InventoryData
class_name ProductInventoryData

var select_mode: bool = false
var num_selected: int = 0

func slot_interact(grabbed_slot_data: SlotData, index: int, action: Slot.Action) -> SlotData:
	if select_mode:
		if grabbed_slot_data:
			return grabbed_slot_data
		match action:
			Slot.Action.Hold:
				return null
			Slot.Action.Click:
				toggle_select_slot_data(index)
			Slot.Action.RightClick:
				pass
	else:
		match action:
			Slot.Action.Hold:
				if grabbed_slot_data:
					return grabbed_slot_data
				select_first_slot_data(index)
				return null
			Slot.Action.Click:
				if grabbed_slot_data:
					return drop_slot_data(grabbed_slot_data, index)
				else:
					return grab_slot_data(index)
			Slot.Action.RightClick:
				pass
	return grabbed_slot_data

func toggle_select_slot_data(index: int) -> void:
	assert(select_mode)
	var selected_slot_data = slot_datas[index]
	if selected_slot_data:
		if selected_slot_data.quantity_selected:
			selected_slot_data.quantity_selected = 0
			num_selected -= 1
		else:
			selected_slot_data.quantity_selected = 1
			num_selected += 1
		if not num_selected:
			select_mode = false
			for i in slot_datas.size():
				var slot_data = slot_datas[i]
				if slot_data:
					slot_data.select_mode = false
					inventory_updated.emit(i, slot_data)
		else:
			inventory_updated.emit(index, selected_slot_data)

func select_first_slot_data(index: int) -> void:
	assert(not select_mode)
	var selected_slot_data = slot_datas[index]
	if selected_slot_data:
		selected_slot_data.quantity_selected = 1
		num_selected = 1
		select_mode = true
		for i in slot_datas.size():
			var slot_data = slot_datas[i]
			if slot_data:
				slot_data.select_mode = true
				inventory_updated.emit(i, slot_data)

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data and slot_data.quantity > 0:
		slot_data.quantity -= 1
		inventory_updated.emit(index, slot_data)
		var ret_slot_data: SlotData = SlotData.new()
		ret_slot_data.item_data = slot_data.item_data
		ret_slot_data.quantity = 1
		return ret_slot_data
	else:
		return null

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var grabbed_product_item_data := grabbed_slot_data.item_data as ProductItemData

	if not grabbed_product_item_data:
		return grabbed_slot_data

	for i in slot_datas.size():
		var slot_data: SlotData = slot_datas[i]
		if slot_data and slot_data.item_data == grabbed_product_item_data:
			slot_data.quantity += 1
			inventory_updated.emit(i, slot_data)
			return null

	return grabbed_slot_data
