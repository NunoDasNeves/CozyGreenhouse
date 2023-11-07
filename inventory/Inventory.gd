extends PanelContainer
class_name Inventory

@export var slot_scene = preload("res://inventory/Slot.tscn")
@onready var item_grid: GridContainer = $MarginContainer/ItemGrid

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory_data)

func populate_item_grid(inventory_data: InventoryData) -> void:
	for child in item_grid.get_children():
		child.queue_free()

	for slot_data in inventory_data.slot_datas:
		var slot: Slot = slot_scene.instantiate()
		item_grid.add_child(slot)#, inventory_data is SeedInventoryData)
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		slot.set_slot_data(slot_data)
		#print(slot.name)
		assert(slot.slot_clicked.get_connections().size() == 1)

func mouse_button_input(event: InputEventMouseButton) -> bool:
	var rect = get_global_rect()
	# WARNING: event.global_position is NOT the canvas layer position
	if rect.has_point(get_global_mouse_position()):
		for slot in item_grid.get_children():
			if (slot as Slot).mouse_button_input(event):
				return true
	return false
