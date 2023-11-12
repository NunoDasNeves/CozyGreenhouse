extends Slot
class_name ProductSlot

@export var container: Node2D
@export var quantity_label: Label
@export var selected_vis: Control
@export var unselected_vis: Control

func set_slot_data(slot_data: SlotData) -> void:
	for child in container.get_children():
		child.queue_free()
	quantity_label.hide()
	selected_vis.hide()
	unselected_vis.hide()
	tooltip_text = ""

	if not slot_data:
		return

	var item_data: ProductItemData = slot_data.item_data
	if not item_data:
		return

	var node := item_data.scene.instantiate() as Node2D
	container.add_child(node)
	var item_scene := node as ItemScene
	assert(item_scene)
	item_scene.set_item_data(item_data)

	if slot_data.quantity == 0:
		node.modulate = Color(Color.WHITE, 0.5)
	else:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()

	if slot_data.select_mode:
		unselected_vis.show()
		if slot_data.quantity_selected:
			selected_vis.show()

	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
