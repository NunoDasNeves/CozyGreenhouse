extends PanelContainer

const slot_scene = preload("res://inventory/Slot.tscn")
@onready var item_grid: GridContainer = $MarginContainer/ItemGrid

func _ready() -> void:
	var inv_data = preload("res://TestInv.tres")
	populate_item_grid(inv_data.slot_datas)

func populate_item_grid(slot_datas: Array[SlotData]) -> void:
	for child in item_grid.get_children():
		child.queue_free()

	for slot_data in slot_datas:
		var slot: Slot = slot_scene.instantiate()
		item_grid.add_child(slot)
		slot.set_slot_data(slot_data)
