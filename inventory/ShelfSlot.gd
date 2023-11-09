extends Slot
class_name ShelfSlot

@onready var container: Node2D = $Container

func set_slot_data(slot_data: SlotData) -> void:
	for child in container.get_children():
		child.queue_free()

	if not slot_data:
		tooltip_text = ""
		return

	var item_data: ItemData = slot_data.item_data
	var node := item_data.scene.instantiate() as Node2D
	container.add_child(node)
	if item_data as RackItemData: # pots are RackItemData
		(node as RackItem).set_item_data(item_data)
	elif item_data as PlantItemData:
		(node as PlantItem).set_item_data(item_data)
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
