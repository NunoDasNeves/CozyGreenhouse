extends InventoryData
class_name ProductInventoryData

var select_mode: bool = false
var frames_held: int = 0

func slot_interact(grabbed_slot_data: SlotData, index: int, action: Slot.Action) -> SlotData:
	if action == Slot.Action.Hold:
		return select_slot_data(index)
	if action != Slot.Action.Click:
		return grabbed_slot_data
	if grabbed_slot_data:
		return drop_slot_data(grabbed_slot_data, index)
	else:
		return grab_slot_data(index)

func select_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data:
		if slot_data.quantity_selected:
			slot_data.quantity_selected = 0
		else:
			slot_data.quantity_selected = 1
		inventory_updated.emit(index, slot_data)
	return null

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
