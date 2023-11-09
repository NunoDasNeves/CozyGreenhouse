extends PanelContainer
class_name Slot

signal slot_clicked(index: int, button: int)

func set_slot_data(slot_data: SlotData) -> void:
	pass

func mouse_button_input(event: InputEventMouseButton) -> bool:
	var rect = get_global_rect()
	# WARNING: event.global_position is NOT the canvas layer position
	if not rect.has_point(get_global_mouse_position()):
		return false
	if event.button_index != MOUSE_BUTTON_LEFT \
			or not event.is_pressed():
		return false

	slot_clicked.emit(get_index(), event.button_index)
	return true
