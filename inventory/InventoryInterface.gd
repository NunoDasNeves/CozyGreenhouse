extends Control
class_name InventoryInterface

var grabbed_slot_data: SlotData
var grabbed_slot_inventory_data: InventoryData
var grabbed_slot_index: int

@onready var next_day_button: Button = $NextDayButton
@onready var grab_slot: Node2D = $GrabSlot
@onready var day_num: Label = $DayNum
@onready var water_tank_bar: ProgressBar = $WaterTankBar

@onready var seed_inventory: Inventory = $SeedInventory
@onready var shelf_inventory: Inventory = $ShelfInventory
@onready var pots_inventory: Inventory = $PotsInventory
@onready var tools_inventory: Inventory = $ToolsInventory

@export var seed_inventory_data: RackInventoryData
@export var shelf_inventory_data: ShelfInventoryData
@export var pot_inventory_data: RackInventoryData
@export var tools_inventory_data: RackInventoryData

func _ready() -> void:
	update_water_tank()
	next_day_button.button_down.connect(next_day)
	add_inventory(seed_inventory, seed_inventory_data)
	add_inventory(shelf_inventory, shelf_inventory_data)
	add_inventory(pots_inventory, pot_inventory_data)
	add_inventory(tools_inventory, tools_inventory_data)
	shelf_inventory_data.water_tank_level_updated.connect(update_water_tank)

func add_inventory(inventory: Inventory, inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	inventory.set_inventory_data(inventory_data)

func process_grabbed_slot() -> void:
	if grab_slot.visible:
		grab_slot.global_position = get_global_mouse_position()

func _physics_process(delta: float) -> void:
	process_grabbed_slot()
	if Input.is_action_just_pressed("rmb"):
		if grabbed_slot_data:
			grabbed_slot_inventory_data.drop_slot_data(grabbed_slot_data, grabbed_slot_index)
			grabbed_slot_data = null
			grabbed_slot_inventory_data = null
			update_grabbed_slot()

func on_inventory_interact(inventory_data: InventoryData, index: int, button: int) -> void:
	var old_grabbed_slot_data = grabbed_slot_data
	grabbed_slot_data = inventory_data.slot_interact(grabbed_slot_data, index, button)

	if button == MOUSE_BUTTON_LEFT:
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
	for i in shelf_inventory_data.slot_datas.size():
		var slot_data: SlotData = shelf_inventory_data.slot_datas[i]
		if not slot_data:
			continue
		var plant_data := slot_data.item_data as PlantItemData
		if not plant_data:
			continue
		plant_data.next_day()
		shelf_inventory_data.inventory_updated.emit(i, slot_data)
