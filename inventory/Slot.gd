extends PanelContainer
class_name Slot

signal slot_clicked(index: int, button: int)

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel

func set_slot_data(slot_data: SlotData) -> void:
	if slot_data:
		var item_data = slot_data.item_data
		texture_rect.texture = item_data.texture
		tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
		texture_rect.modulate = Color.WHITE
		if item_data is SeedItemData:
			quantity_label.text = "x%s" % slot_data.quantity
			quantity_label.show()
			if slot_data.quantity == 0:
				texture_rect.modulate = Color(Color.WHITE, 0.5)
		elif slot_data.quantity > 1:
			quantity_label.text = "x%s" % slot_data.quantity
			quantity_label.show()
		else:
			quantity_label.hide()
	else:
		texture_rect.texture = null
		tooltip_text = ""
		quantity_label.hide()

func _on_gui_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if not mouse_event:
		return

	if (mouse_event.button_index == MOUSE_BUTTON_LEFT \
			or mouse_event.button_index == MOUSE_BUTTON_RIGHT) \
			and mouse_event.is_pressed():
		slot_clicked.emit(get_index(), mouse_event.button_index)
