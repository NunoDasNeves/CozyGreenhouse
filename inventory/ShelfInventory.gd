extends Inventory
class_name ShelfInventory

func populate_item_grid() -> void:
	var shelf_inventory_data := inventory_data as ShelfInventoryData
	for slot_data in inventory_data.slot_datas:
		var slot: ShelfSlot = slot_scene.instantiate()
		item_grid.add_child(slot)
		slot.slot_clicked.connect(on_slot_interact)
		slot.fruit_gathered.connect(shelf_inventory_data.gather_fruit)
		slot.set_slot_data(slot_data)
