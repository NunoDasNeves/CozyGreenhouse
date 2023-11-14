extends Resource
class_name State

@export var curr_day: int = 0
@export var water_tank_level: float = 10
@export var max_water_tank_level: float = 25
@export var money: float = 10

@export var seed_inventory_data: RackInventoryData
@export var pot_inventory_data: RackInventoryData
@export var tool_inventory_data: RackInventoryData
@export var shelf_inventory_data: ShelfInventoryData
@export var sell_inventory_data: ProductInventoryData
@export var buy_inventory_data: ProductInventoryData

var grab_data: GrabSlotData = GrabSlotData.new()

func next_day() -> void:
	grab_data.dismiss() # not really needed because called in inventory interface, but should be here anyway
	# TODO other inventories need this?
	shelf_inventory_data.next_day()
	curr_day += 1

func try_use_water(amount: float) -> float:
	var water_left: float = water_tank_level
	var water_to_use = minf(amount, water_left)
	water_tank_level -= water_to_use
	return water_to_use

func add_products_to_sell(products: Array[ProductItemData]) -> void:
	for product in products:
		var product_slot_data: SlotData = SlotData.new()
		product_slot_data.item_data = product
		product_slot_data.quantity = 1
		sell_inventory_data.drop_slot_data(product_slot_data, 0)
