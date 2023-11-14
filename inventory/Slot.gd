extends PanelContainer
class_name Slot

enum Action {
	None,
	Click,
	Hold,
	RightClick,
}

const LMB_HOLD_TIME: float = 0.5
var lmb_hold_time: float = 0
var lmb_pressed: bool = false

signal slot_clicked(index: int, action: Action)

func set_slot_data(slot_data: SlotData) -> void:
	pass

func _process(delta: float) -> void:
	if lmb_pressed:
		if lmb_hold_time < LMB_HOLD_TIME:
			lmb_hold_time += delta
		else:
			slot_clicked.emit(get_index(), Action.Hold)
			lmb_pressed = false

func _gui_input(event: InputEvent) -> void:
	var mouse_button_event := event as InputEventMouseButton
	if not mouse_button_event:
		return
	var is_pressed: bool = mouse_button_event.is_pressed()
	var button: int = mouse_button_event.button_index
	var action: Action = Action.None
	match(button):
		MOUSE_BUTTON_LEFT:
			if is_pressed:
				lmb_pressed = true
				lmb_hold_time = 0
			if not is_pressed:
				lmb_pressed = false
				if lmb_hold_time < LMB_HOLD_TIME:
					action = Action.Click
		MOUSE_BUTTON_RIGHT:
			if not is_pressed:
				action = Action.RightClick

	if action == Action.None:
		return

	slot_clicked.emit(get_index(), action)
