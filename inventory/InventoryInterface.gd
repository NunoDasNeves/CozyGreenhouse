extends Control
class_name InventoryInterface

var grabbed_slot_data: SlotData
var grabbed_slot_inventory_data: InventoryData
var grabbed_slot_index: int

@onready var grabbed_slot: Slot = $GrabbedSlot

@onready var some_inventory: Inventory = $SomeInventory
@onready var seed_inventory: Inventory = $SeedInventory
@onready var shelf_inventory: Inventory = $ShelfInventory

@export var test_inventory_data: InventoryData
@export var seed_inventory_data: SeedInventoryData
@export var shelf_inventory_data: ShelfInventoryData

func _ready() -> void:
	add_inventory(some_inventory, test_inventory_data)
	add_inventory(seed_inventory, seed_inventory_data)
	add_inventory(shelf_inventory, shelf_inventory_data)

func add_inventory(inventory: Inventory, inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	inventory.set_inventory_data(inventory_data)

func _physics_process(delta: float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5,5)
	if Input.is_action_just_pressed("rmb"):
		if grabbed_slot_data:
			grabbed_slot_inventory_data.drop_slot_data(grabbed_slot_data, grabbed_slot_index)
			grabbed_slot_data = null
			grabbed_slot_inventory_data = null
			update_grabbed_slot()

func on_inventory_interact(inventory_data: InventoryData, index: int, button: int) -> void:
	var old_grabbed_slot_data = grabbed_slot_data
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
		#[_, MOUSE_BUTTON_RIGHT]:
		#	grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)

	if grabbed_slot_data != old_grabbed_slot_data and button == MOUSE_BUTTON_LEFT:
		grabbed_slot_inventory_data = inventory_data
		grabbed_slot_index = index

	update_grabbed_slot()

func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()
