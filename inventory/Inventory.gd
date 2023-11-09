extends PanelContainer
class_name Inventory

@export var slot_scene: PackedScene
@onready var item_grid: GridContainer = $MarginContainer/ItemGrid

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(update_slot)
	populate_item_grid(inventory_data)

func update_slot(index: int, slot_data: SlotData) -> void:
	var slot := item_grid.get_child(index) as Slot
	slot.set_slot_data(slot_data)

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
