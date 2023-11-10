extends Control
class_name InventoryInterface

var grabbed_slot_data: SlotData
var grabbed_slot_inventory_data: InventoryData
var grabbed_slot_index: int
var curr_day: int

@onready var next_day_button: Button = $NextDayButton
@onready var grab_slot: Node2D = $GrabSlot
@onready var day_num: Label = $DayNum

@onready var seed_inventory: Inventory = $SeedInventory
@onready var shelf_inventory: Inventory = $ShelfInventory
@onready var pots_inventory: Inventory = $PotsInventory
@onready var tools_inventory: Inventory = $ToolsInventory

@export var seed_inventory_data: RackInventoryData
@export var shelf_inventory_data: ShelfInventoryData
@export var pot_inventory_data: RackInventoryData
@export var tools_inventory_data: RackInventoryData

func _ready() -> void:
	curr_day = 0
	next_day_button.button_down.connect(next_day)
	add_inventory(seed_inventory, seed_inventory_data)
	add_inventory(shelf_inventory, shelf_inventory_data)
	add_inventory(pots_inventory, pot_inventory_data)
	add_inventory(tools_inventory, tools_inventory_data)

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

	if grabbed_slot_data != old_grabbed_slot_data and button == MOUSE_BUTTON_LEFT:
		grabbed_slot_inventory_data = inventory_data
		grabbed_slot_index = index

	update_grabbed_slot()

func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		for child in grab_slot.get_children():
			child.queue_free()
		var item_data := grabbed_slot_data.item_data
		var node := item_data.scene.instantiate() as Node2D
		grab_slot.add_child(node)
		if item_data as RackItemData: # pots are RackItemData
			(node as RackItemScene).set_item_data(item_data)
		elif item_data as PlantItemData:
			(node as PlantItemScene).set_item_data(item_data)
		grab_slot.show()
		process_grabbed_slot()
	else:
		grab_slot.hide()

func next_day() -> void:
	curr_day += 1
	day_num.text = "Day: %s" % curr_day
	for i in shelf_inventory_data.slot_datas.size():
		var slot_data: SlotData = shelf_inventory_data.slot_datas[i]
		if not slot_data:
			continue
		var plant_data := slot_data.item_data as PlantItemData
		if not plant_data:
			continue
		plant_data.light.next_day()
		plant_data.water.next_day()
		plant_data.fertilizer.next_day()
		shelf_inventory_data.inventory_updated.emit(i, slot_data)
		
