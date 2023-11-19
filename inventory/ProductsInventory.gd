extends Inventory
class_name ProductsInventory

@onready var help_text: Label = $"VBoxContainer/MarginContainer3/Help text"
@onready var action: Button = $VBoxContainer/MarginContainer2/HBoxContainer/Action
@onready var total_label: Label = $VBoxContainer/MarginContainer2/HBoxContainer/TotalLabel

func populate_item_grid() -> void:
	var prod_inventory_data := inventory_data as ProductInventoryData
	for slot_data in inventory_data.slot_datas:
		var slot: ProductSlot = slot_scene.instantiate()
		item_grid.add_child(slot)
		slot.prod_inventory_type = prod_inventory_data.inventory_type
		slot.slot_clicked.connect(on_slot_interact)
		slot.quantity_selected_changed.connect(prod_inventory_data.change_quantity_selected)
		slot.set_slot_data(slot_data)

func init(inv_data: InventoryData) -> void:
	super.init(inv_data)
	var prod_inventory_data := inventory_data as ProductInventoryData
	Global.disconnect_signal(action.button_down)
	action.button_down.connect(prod_inventory_data.action_pressed)
	Global.disconnect_signal(prod_inventory_data.action_button_updated)
	Global.disconnect_signal(prod_inventory_data.select_mode_updated)
	Global.disconnect_signal(prod_inventory_data.total_value_updated)
	prod_inventory_data.action_button_updated.connect(update_action_button)
	prod_inventory_data.select_mode_updated.connect(update_select_mode)
	prod_inventory_data.total_value_updated.connect(update_total_value)
	update_action_button()
	update_select_mode()

func update_select_mode() -> void:
	var prod_inventory_data := inventory_data as ProductInventoryData
	if prod_inventory_data.select_mode:
		total_label.show()
		action.disabled = false
		help_text.text = "Click to (de)select items"
	else:
		total_label.hide()
		action.disabled = true
		if prod_inventory_data.inventory_type == ProductInventoryData.Type.Sell:
			help_text.text = "Click to select. Hold to drag"
		else:
			help_text.text = "Click to select items"

func update_action_button() -> void:
	var prod_inventory_data := inventory_data as ProductInventoryData
	action.text = prod_inventory_data.action_text

func update_total_value(value: float) -> void:
	total_label.text = "Total:\n%sĦ" % value
