extends PanelContainer
class_name Inventory

@export var slot_scene: PackedScene
@export var item_grid: GridContainer
@export var inventory_data: InventoryData
@export var buttons: Array[Button]
@export var labels: Array[Label]

signal inventory_interact(inventory: Inventory, index: int, action: Slot.Action)

func connect_and_populate() -> void:
	inventory_data.inventory_updated.connect(update_slot)
	if buttons:
		for button in buttons:
			button.button_down.connect(button_pressed)
			inventory_data.button_label_updated.connect(update_button_text)
			inventory_data.button_enable_updated.connect(update_button_enable)
	if labels:
		for label in labels:
			inventory_data.label_updated.connect(update_label)
	populate_item_grid()

func _ready() -> void:
	# you can't (ever?) add child nodes properly in _ready.
	# so defer this. ugh
	call_deferred("connect_and_populate")

func on_slot_interact(index: int, action: Slot.Action):
	inventory_interact.emit(self, index, action)

func update_inventory_data(new_inventory_data: InventoryData) -> void:
	inventory_data = new_inventory_data
	connect_and_populate()

func button_pressed() -> void:
	for i in buttons.size():
		var button: Button = buttons[i]
		if button.button_pressed:
			inventory_data.button_pressed(i)
			break

func update_label(index: int, text: String) -> void:
	var label: Label = labels[index]
	if not label:
		return
	label.text = text

func update_button_text(index: int, text: String) -> void:
	var button: Button = buttons[index]
	if not button:
		return
	button.text = text

func update_button_enable(index: int, enabled: bool) -> void:
	var button: Button = buttons[index]
	if not button:
		return
	button.disabled = not enabled

func update_slot(index: int, slot_data: SlotData) -> void:
	var slot := item_grid.get_child(index) as Slot
	slot.set_slot_data(slot_data)

func populate_item_grid() -> void:
	for child in item_grid.get_children():
		child.queue_free()

	for slot_data in inventory_data.slot_datas:
		var slot: Slot = slot_scene.instantiate()
		item_grid.add_child(slot)#, inventory_data is SeedInventoryData)
		slot.slot_clicked.connect(on_slot_interact)
		slot.set_slot_data(slot_data)
		#print(slot.name)
		assert(slot.slot_clicked.get_connections().size() == 1)
