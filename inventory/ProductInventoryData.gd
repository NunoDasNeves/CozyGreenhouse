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
	assert(select_mode)
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

func action_pressed() -> void:
	if not select_mode:
		return
	assert(num_selected)
	match inventory_type:
		Type.Sell:
			var total_value: float = 0
			for slot_data in slot_datas:
				if not slot_data or not slot_data.quantity_selected:
					continue
				assert(slot_data.quantity >= slot_data.quantity_selected)
				var product_data := slot_data.item_data as ProductItemData
				total_value += slot_data.quantity_selected * product_data.value
				slot_data.quantity -= slot_data.quantity_selected
				slot_data.quantity_selected = 0
			Global.money += total_value
			money_updated.emit()
			pack_slot_datas()
			change_select_mode(false)
		Type.Buy:
			pass

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

func select_slot_data(index: int, quantity: int = 0) -> void:
	var selected_slot_data = slot_datas[index]
	if not selected_slot_data:
		return

	selected_slot_data.quantity_selected = quantity if quantity else selected_slot_data.quantity

	if not select_mode:
		change_select_mode(true)
	else:
		num_selected += 1
		inventory_updated.emit(index, selected_slot_data)

func deselect_slot_data(index: int) -> void:
	assert(select_mode)
	var selected_slot_data = slot_datas[index]
	if not selected_slot_data:
		return

	if selected_slot_data.quantity_selected:
		selected_slot_data.quantity_selected = 0
		num_selected -= 1

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

	# TODO drop in empty slot so new items can be dropped in!

	return grabbed_slot_data
