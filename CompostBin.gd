extends TextureButton
class_name CompostBin

signal composted_grabbed_item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed() -> void:
	var slot_data: SlotData = Global.state.grab_data.slot_data
	if not slot_data:
		return
	var item_data: ItemData = slot_data.item_data
	var compost_component: CompostComponent = item_data.get_component("Compost")
	if not compost_component:
		return
	var compost_value: float = compost_component.get_compost_value(item_data)
	Global.state.add_compost(compost_value)
	composted_grabbed_item.emit()
