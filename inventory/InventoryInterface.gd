extends Control
class_name InventoryInterface

var grabbed_slot_data: SlotData
var grabbed_slot_scene: PackedScene = preload("res://inventory/RackSlot.tscn")
var grabbed_slot_inventory_data: InventoryData
var grabbed_slot_index: int

@onready var grabbed_slot: Slot = $GrabbedSlot

@onready var seed_inventory: Inventory = $SeedInventory
@onready var shelf_inventory: Inventory = $ShelfInventory
@onready var pots_inventory: Inventory = $PotsInventory

@export var seed_inventory_data: SeedInventoryData
@export var shelf_inventory_data: ShelfInventoryData
@export var pots_inventory_data: InventoryData

func _ready() -> void:
	add_inventory(seed_inventory, seed_inventory_data)
	add_inventory(shelf_inventory, shelf_inventory_data)
	add_inventory(pots_inventory, pots_inventory_data)

func add_inventory(inventory: Inventory, inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	inventory.set_inventory_data(inventory_data)

func process_grabbed_slot() -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(-150,-150)

func _physics_process(delta: float) -> void:
	process_grabbed_slot()
	if Input.is_action_just_pressed("rmb"):
		if grabbed_slot_data:
			grabbed_slot_inventory_data.drop_slot_data(grabbed_slot_data, grabbed_slot_index)
			grabbed_slot_data = null
			grabbed_slot_inventory_data = null
			update_grabbed_slot()

func _input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if not mouse_event:
		return

	for child in get_children():
		var inventory := child as Inventory
		if not inventory:
			continue
		if inventory.mouse_button_input(mouse_event):
			break

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
		grabbed_slot_scene = inventory_data

	update_grabbed_slot()

func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
		process_grabbed_slot()
	else:
		grabbed_slot.hide()
