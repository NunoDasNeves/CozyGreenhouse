extends Inventory
class_name ShelfInventory

func populate_item_grid() -> void:
	var shelf_inventory_data := inventory_data as ShelfInventoryData
	shelf_inventory_data.attach_slot_updated.connect(update_attach_slot)
	for i in inventory_data.slot_datas.size():
		var slot_data: SlotData = shelf_inventory_data.slot_datas[i]
		var attach_slot_data: SlotData = shelf_inventory_data.attach_slot_datas[i]
		var light_data: LightData = shelf_inventory_data.light_datas[i]
		var slot: ShelfSlot = slot_scene.instantiate()
		item_grid.add_child(slot)
		slot.slot_clicked.connect(on_slot_interact)
		slot.fruit_gathered.connect(shelf_inventory_data.gather_fruit)
		slot.set_slot_data(slot_data)
		slot.set_attachment(attach_slot_data)
		slot.set_light(light_data)

func update_attach_slot(index: int) -> void:
	var shelf_inventory_data := inventory_data as ShelfInventoryData
	var attach_data: SlotData = shelf_inventory_data.attach_slot_datas[index]
	var slot := item_grid.get_child(index) as ShelfSlot
	slot.set_attachment(attach_data)
