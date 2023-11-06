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
		if item_data is SeedItemData or item_data is ShelfItemData:
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
