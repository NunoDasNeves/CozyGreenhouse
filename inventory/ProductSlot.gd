extends Slot
class_name ProductSlot

@onready var container: Node2D = $Container
@onready var quantity_label: Label = $MarginContainer/QuantityLabel
@onready var price_label: Label = $MarginContainer/PriceLabel
@onready var quantity_selected_input: LineEdit = $MarginContainer/QuantitySelectedInput
@onready var selected_vis: Control = $Selected
@onready var unselected_vis: Control = $Unselected

var prod_inventory_type: ProductInventoryData.Type

signal quantity_selected_changed(index: int, num: int)

func on_quantity_selected_changed(text: String) -> void:
	if text.is_valid_int():
		quantity_selected_changed.emit(get_index(), text as int)

func set_slot_data(slot_data: SlotData) -> void:
	for child in container.get_children():
		child.queue_free()
	quantity_label.hide()
	selected_vis.hide()
	unselected_vis.hide()
	price_label.hide()
	quantity_selected_input.hide()
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

	var prod_item_data := slot_data.item_data as ProductItemData
	var item_value: float = 0

	if prod_item_data:
		item_value = prod_item_data.value
	else:
		match prod_inventory_type:
			ProductInventoryData.Type.Sell:
				var sell_component = item_data.get_component("Sell") as SellComponent
				item_value = sell_component.base_value
			ProductInventoryData.Type.Buy:
				var buy_component = item_data.get_component("Buy") as BuyComponent
				item_value = buy_component.base_value

	var slot_display_price: float = item_value
	var slot_price_color: Color = Color.LIGHT_GRAY
	if slot_data.select_mode:
		unselected_vis.show()
		if slot_data.quantity_selected:
			slot_display_price = slot_data.quantity_selected * item_value
			slot_price_color = Color.GOLD
			selected_vis.show()
			if slot_data.quantity > 1:
				quantity_selected_input.show()
				quantity_selected_input.text = "%s" % slot_data.quantity_selected
	price_label.remove_theme_color_override("font_color")
	price_label.add_theme_color_override("font_color", slot_price_color)
	price_label.text = "$%s" % slot_display_price
	price_label.show()

	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
