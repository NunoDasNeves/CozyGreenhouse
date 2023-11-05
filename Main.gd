extends Node

@export var inventory_data: InventoryData
@onready var inventory_interface: InventoryInterface = $UI/InventoryInterface

func _ready() -> void:
	inventory_interface.set_some_inventory_data(inventory_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
