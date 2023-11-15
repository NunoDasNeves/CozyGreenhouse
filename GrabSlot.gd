extends Node2D
class_name GrabSlot

@onready var container: Node2D = $Container
@onready var quantity_label: Label = $QuantityLabel

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
		quantity_label.hide()
		for child in container.get_children():
			child.queue_free()

		var item_data := grab_data.slot_data.item_data
		var node := item_data.scene.instantiate() as Node2D
		container.add_child(node)
		var item_scene = node as ItemScene
		assert(item_scene)
		item_scene.set_item_data(item_data)

		var stackable_component := item_data.get_component("Stackable") as StackableComponent
		if stackable_component:
			var quantity: int = grab_data.slot_data.quantity
			if stackable_component.show_1x_quantity or quantity > 1:
				quantity_label.text = "x%s" % quantity
				quantity_label.show()
		else:
			quantity_label.text = "x%s" % grab_data.slot_data.quantity
			quantity_label.show()

		show()
		process()
	else:
		hide()
