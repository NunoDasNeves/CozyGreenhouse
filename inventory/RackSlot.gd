extends Slot
class_name RackSlot

@onready var container: Node2D = $Container
@onready var quantity_label: Label = $QuantityLabel

func set_slot_data(slot_data: SlotData) -> void:
	for child in container.get_children():
		child.queue_free()
	quantity_label.hide()
	tooltip_text = ""

	if not slot_data:
		return

	var item_data: ItemData = slot_data.item_data

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
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
