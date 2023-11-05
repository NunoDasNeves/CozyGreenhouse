extends Node

@export var test_inventory_data: InventoryData
@export var seed_inventory_data: SeedInventoryData
@onready var inventory_interface: InventoryInterface = $UI/InventoryInterface

func _ready() -> void:
	inventory_interface.set_some_inventory_data(test_inventory_data)
	inventory_interface.set_seed_inventory_data(seed_inventory_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
