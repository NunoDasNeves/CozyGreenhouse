extends Inventory
class_name ShelfInventory

func populate_item_grid() -> void:
	var shelf_inventory_data := inventory_data as ShelfInventoryData
	for slot_data in inventory_data.slot_datas:
		var slot: ShelfSlot = slot_scene.instantiate()
		item_grid.add_child(slot)
		slot.slot_clicked.connect(on_slot_interact)
		slot.fruit_gathered.connect(shelf_inventory_data.gather_fruit)
		shelf_inventory_data.slot_light_updated.connect(update_slot_light)
		slot.set_slot_data(slot_data)

func update_slot_light(index: int) -> void:
	var shelf_inventory_data := inventory_data as ShelfInventoryData
	var light_level: float = shelf_inventory_data.light_levels[index]
	var slot := item_grid.get_child(index) as ShelfSlot
	slot.set_light_level(light_level)
