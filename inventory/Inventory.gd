extends PanelContainer
class_name Inventory

@export var slot_scene: PackedScene
@export var item_grid: GridContainer
var inventory_data: InventoryData

signal play_click
signal inventory_interact(inventory: Inventory, index: int, action: Slot.Action)

func init(inv_data: InventoryData) -> void:
	inventory_data = inv_data
	inventory_data.init()
	Global.disconnect_signal(inventory_data.slot_updated)
	Global.disconnect_signal(inventory_data.slot_appended)
	inventory_data.slot_updated.connect(update_slot)
	inventory_data.slot_appended.connect(append_slot)
	clear_item_grid()
	populate_item_grid()

func on_slot_interact(index: int, action: Slot.Action):
	inventory_interact.emit(self, index, action)

func append_slot(slot_data: SlotData) -> void:
	var slot: Slot = slot_scene.instantiate()
	item_grid.add_child(slot)
	slot.slot_clicked.connect(on_slot_interact)
	slot.set_slot_data(slot_data)
	assert(slot.slot_clicked.get_connections().size() == 1)

func update_slot(index: int) -> void:
	var slot_data: SlotData = inventory_data.slot_datas[index]
	var slot := item_grid.get_child(index) as Slot
	slot.set_slot_data(slot_data)

func clear_item_grid() -> void:
	for child in item_grid.get_children():
		child.queue_free()

func populate_item_grid() -> void:
	for slot_data in inventory_data.slot_datas:
		append_slot(slot_data)
