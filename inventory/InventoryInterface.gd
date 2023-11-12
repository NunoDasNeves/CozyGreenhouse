extends Control
class_name InventoryInterface

var grabbed_slot_data: SlotData
var grabbed_slot_inventory_data: InventoryData
var grabbed_slot_index: int

@onready var next_day_button: Button = $NextDayButton
@onready var grab_slot: Node2D = $GrabSlot
@onready var day_num: Label = $DayNum
@onready var water_tank_bar: ProgressBar = $WaterTankBar

@export var inventories: Array[Inventory]

func _ready() -> void:
	for inventory in inventories:
		inventory.inventory_interact.connect(on_inventory_interact)
		inventory.inventory_data.water_tank_level_updated.connect(update_water_tank)
	update_water_tank()
	next_day_button.button_down.connect(next_day)

func process_grabbed_slot() -> void:
	if grab_slot.visible:
		grab_slot.global_position = get_global_mouse_position()

func _physics_process(delta: float) -> void:
	process_grabbed_slot()

func _input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
		if grabbed_slot_data:
			var old_grabbed_slot_data = grabbed_slot_data
			grabbed_slot_data = grabbed_slot_inventory_data.drop_slot_data(grabbed_slot_data, grabbed_slot_index)
			if not grabbed_slot_data:
				grabbed_slot_inventory_data = null
			update_grabbed_slot()
			accept_event()

func on_inventory_interact(inventory: Inventory, index: int, action: Slot.Action) -> void:
	var old_grabbed_slot_data = grabbed_slot_data
	var inventory_data: InventoryData = inventory.inventory_data
	# ignore rmb if holding something - we should drop it. handle in physics process
	if action == Slot.Action.RightClick:
		if grabbed_slot_data:
			return

	grabbed_slot_data = inventory_data.slot_interact(grabbed_slot_data, index, action)

	if grabbed_slot_data != old_grabbed_slot_data:
		grabbed_slot_inventory_data = inventory_data
		grabbed_slot_index = index

	if grabbed_slot_data != old_grabbed_slot_data:
		update_grabbed_slot()

func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		for child in grab_slot.get_children():
			child.queue_free()
		var item_data := grabbed_slot_data.item_data
		var node := item_data.scene.instantiate() as Node2D
		grab_slot.add_child(node)
		if node as RackItemScene: # pots are RackItemData
			(node as RackItemScene).set_item_data(item_data)
		elif item_data as PlantItemData:
			(node as PlantItemScene).set_item_data(item_data)
		grab_slot.show()
		process_grabbed_slot()
	else:
		grab_slot.hide()

func update_water_tank() -> void:
	var old_water_level: float = water_tank_bar.value
	water_tank_bar.max_value = Global.max_water_tank_level
	water_tank_bar.value = Global.water_tank_level
	if old_water_level > 0:
		var grab_scene: Node2D = grab_slot.get_child(0)
		if grab_scene and grab_scene is WateringCanScene:
			(grab_scene as WateringCanScene).play_anim()

func next_day() -> void:
	Global.next_day()
	day_num.text = "Day: %s" % Global.curr_day
	for inventory in inventories:
		inventory.inventory_data.next_day()
