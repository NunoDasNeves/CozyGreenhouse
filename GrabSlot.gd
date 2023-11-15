extends Node2D
class_name GrabSlot

var grab_data: GrabData

func process() -> void:
	if visible:
		global_position = get_global_mouse_position()

func _physics_process(delta: float) -> void:
	process()

func dismiss() -> bool:
	if grab_data.dismiss():
		update()
		return true
	return false

func on_inventory_interact(inventory: Inventory, index: int, action: Slot.Action) -> void:
	var do_update: bool = grab_data.inventory_interact(inventory.inventory_data, index, action)
	if do_update:
		update()

func update() -> void:
	if grab_data.slot_data:
		for child in get_children():
			child.queue_free()
		var item_data := grab_data.slot_data.item_data
		var node := item_data.scene.instantiate() as Node2D
		add_child(node)
		var item_scene = node as ItemScene
		assert(item_scene)
		item_scene.set_item_data(item_data)
		show()
		process()
	else:
		hide()
