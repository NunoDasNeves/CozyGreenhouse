extends Slot
class_name ProductSlot

@export var container: Node2D
@export var quantity_label: Label
@export var selected_panel: Panel

func set_slot_data(slot_data: SlotData) -> void:
	for child in container.get_children():
		child.queue_free()
	quantity_label.hide()
	selected_panel.hide()
	tooltip_text = ""

	if not slot_data:
		return

	var item_data: ProductItemData = slot_data.item_data
	if not item_data:
		return

	var node := item_data.scene.instantiate() as Node2D
	container.add_child(node)
	if node as ProductItemScene: # pots are RackItemData
		(node as ProductItemScene).set_item_data(item_data)

	if slot_data.quantity == 0:
		node.modulate = Color(Color.WHITE, 0.5)
	else:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()

	if slot_data.quantity_selected:
		selected_panel.show()
	else:
		selected_panel.hide()
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
