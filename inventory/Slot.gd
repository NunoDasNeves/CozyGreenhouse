extends PanelContainer
class_name Slot

signal slot_clicked(index: int, button: int)

func set_slot_data(slot_data: SlotData) -> void:
	pass

func _gui_input(event: InputEvent) -> void:
	var mouse_button_event := event as InputEventMouseButton
	if not mouse_button_event:
		return
	if mouse_button_event.is_pressed():
		slot_clicked.emit(get_index(), mouse_button_event.button_index)
