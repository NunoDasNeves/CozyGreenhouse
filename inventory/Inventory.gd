extends PanelContainer
class_name Inventory

@export var slot_scene: PackedScene
@export var item_grid: GridContainer
@export var inventory_data: InventoryData

signal inventory_interact(inventory: Inventory, index: int, action: Slot.Action)

func connect_and_populate() -> void:
	inventory_data.inventory_updated.connect(update_slot)
	populate_item_grid()

func _ready() -> void:
	connect_and_populate()

func on_slot_interact(index: int, action: Slot.Action):
	inventory_interact.emit(self, index, action)

func update_inventory_data(new_inventory_data: InventoryData) -> void:
	inventory_data = new_inventory_data
	connect_and_populate()

func update_slot(index: int, slot_data: SlotData) -> void:
	var slot := item_grid.get_child(index) as Slot
	slot.set_slot_data(slot_data)

func populate_item_grid() -> void:
	for child in item_grid.get_children():
		child.queue_free()

	for slot_data in inventory_data.slot_datas:
		var slot: Slot = slot_scene.instantiate()
		item_grid.add_child(slot)#, inventory_data is SeedInventoryData)
		slot.slot_clicked.connect(on_slot_interact)
		slot.set_slot_data(slot_data)
		#print(slot.name)
		assert(slot.slot_clicked.get_connections().size() == 1)
