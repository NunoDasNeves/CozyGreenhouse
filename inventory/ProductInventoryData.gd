extends InventoryData
class_name ProductInventoryData

enum Type {
	Sell,
	Buy
}

signal action_button_updated
signal select_mode_updated
signal quantity_selected_updated(index: int, quantity_selected: int)

@export var inventory_type: Type
@export var action_text: String

var select_mode: bool = false
var num_selected: int = 0

func change_quantity_selected(index: int, num: int) -> void:
	var slot_data: SlotData = slot_datas[index]
	if not slot_data:
		return

	num = clampi(num, 0, slot_data.quantity)

	if num == 0:
		deselect_slot_data(index)
	else:
		select_slot_data(index, num)

func change_select_mode(enable: bool) -> void:
	select_mode = enable
	select_mode_updated.emit()
	if select_mode:
		num_selected = 1
	else:
		num_selected = 0

	for i in slot_datas.size():
		var slot_data = slot_datas[i]
		if slot_data:
			slot_data.select_mode = select_mode
		# slot_data can be null here
		inventory_updated.emit(i, slot_data)

func pack_slot_datas() -> void:
	var j = 0
	for i in slot_datas.size():
		j += 1 # j should always be at least i + 1
		var slot_data: SlotData = slot_datas[i]
		if slot_data and slot_data.quantity:
			continue
		slot_datas[i] = null

		while j < slot_datas.size():
			if slot_datas[j] and slot_datas[j].quantity:
				slot_datas[i] = slot_datas[j]
				slot_datas[j] = null
				break
			j += 1

func get_selected_value() -> float:
	var total_value: float = 0
	for slot_data in slot_datas:
		if not slot_data or not slot_data.quantity_selected:
			continue
		assert(slot_data.quantity >= slot_data.quantity_selected)
		match inventory_type:
			Type.Sell:
				var sell_component := slot_data.item_data.get_component("Sell") as SellComponent
				total_value += slot_data.quantity_selected * sell_component.base_value
			Type.Buy:
				var buy_component := slot_data.item_data.get_component("Buy") as BuyComponent
				total_value += slot_data.quantity_selected * buy_component.base_value
	return total_value

func action_pressed() -> void:
	if not select_mode:
		return
	assert(num_selected)
	var total_value: float = get_selected_value()
	match inventory_type:
		Type.Sell:
			for slot_data in slot_datas:
				if not slot_data or not slot_data.quantity_selected:
					continue
				slot_data.quantity -= slot_data.quantity_selected
				slot_data.quantity_selected = 0
			Global.state.add_money(total_value)
			pack_slot_datas()
			change_select_mode(false)
		Type.Buy:
			if not Global.state.try_spend_money(total_value):
				return
			var bought_items: Array[SlotData] = []
			for slot_data in slot_datas:
				if not slot_data or not slot_data.quantity_selected:
					continue
				var new_slot_data: SlotData = SlotData.new()
				new_slot_data.item_data = slot_data.item_data
				new_slot_data.quantity = slot_data.quantity_selected
				bought_items.push_back(new_slot_data)
				slot_data.quantity -= slot_data.quantity_selected
				slot_data.quantity_selected = 0
			Global.state.acquire_items(bought_items)
			pack_slot_datas()
			change_select_mode(false)

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
				match inventory_type:
					Type.Sell:
						if grabbed_slot_data:
							return drop_slot_data(grabbed_slot_data, index)
						else:
							return grab_slot_data(index)
						return null
					Type.Buy:
						if grabbed_slot_data:
							return grabbed_slot_data
						select_first_slot_data(index)
			Slot.Action.Click:
				if grabbed_slot_data:
					return drop_slot_data(grabbed_slot_data, index)
				select_first_slot_data(index)
			Slot.Action.RightClick:
				pass
	return grabbed_slot_data

func select_slot_data(index: int, quantity: int = 0) -> void:
	var selected_slot_data = slot_datas[index]
	if not selected_slot_data:
		return

	assert(selected_slot_data.quantity)
	if !selected_slot_data.quantity_selected:
		num_selected += 1
	selected_slot_data.quantity_selected = quantity if quantity else selected_slot_data.quantity

	if not select_mode:
		change_select_mode(true)
	else:
		inventory_updated.emit(index, selected_slot_data)

func deselect_slot_data(index: int) -> void:
	# IDK why but for text_changed we get 2 events and that breaks
	# this if we assert(select_mode) here
	if not select_mode:
		return

	var selected_slot_data = slot_datas[index]
	if not selected_slot_data:
		return

	if selected_slot_data.quantity_selected:
		num_selected -= 1
		selected_slot_data.quantity_selected = 0

	if not num_selected:
		change_select_mode(false)
	else:
		inventory_updated.emit(index, selected_slot_data)

func toggle_select_slot_data(index: int) -> void:
	assert(select_mode)
	var selected_slot_data = slot_datas[index]
	if selected_slot_data:
		if selected_slot_data.quantity_selected:
			deselect_slot_data(index)
		else:
			select_slot_data(index)

func select_first_slot_data(index: int) -> void:
	assert(not select_mode)
	var selected_slot_data = slot_datas[index]
	if selected_slot_data:
		select_slot_data(index)

func grab_slot_data(index: int) -> SlotData:
	var ret = null
	var slot_data = slot_datas[index]

	if not slot_data:
		return ret

	assert(slot_data.quantity)
	assert(slot_data.item_data)

	slot_data.quantity -= 1
	var ret_slot_data: SlotData = SlotData.new()
	ret_slot_data.item_data = slot_data.item_data
	ret_slot_data.quantity = 1
	ret = ret_slot_data

	if slot_data.quantity == 0:
		slot_data = null
	inventory_updated.emit(index, slot_data)

	return ret

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var grabbed_item_data := grabbed_slot_data.item_data

	if not grabbed_item_data.has_component("Sell"):
		return grabbed_slot_data

	for i in slot_datas.size():
		var slot_data: SlotData = slot_datas[i]
		if slot_data and slot_data.item_data == grabbed_item_data:
			slot_data.quantity += grabbed_slot_data.quantity
			inventory_updated.emit(i, slot_data)
			return null

	for i in slot_datas.size():
		var slot_data: SlotData = slot_datas[i]
		if not slot_data:
			slot_datas[i] = grabbed_slot_data
			return null

	return grabbed_slot_data
