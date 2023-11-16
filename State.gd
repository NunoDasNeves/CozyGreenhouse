extends Resource
class_name State

signal water_updated
signal money_updated

const FERTILIZER_AMOUNT: float = 1
const WATERING_CAN_WATER_AMOUNT: float = 0.5

var water_per_day: float = 0.1

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

var grab_data: GrabData = GrabData.new()

func next_day() -> void:
	grab_data.dismiss() # not really needed because called in inventory interface, but should be here anyway
	# TODO other inventories need this?
	shelf_inventory_data.next_day()
	curr_day += 1
	add_water(water_per_day)

func add_money(amount: float) -> void:
	money += amount
	money_updated.emit()

func try_spend_money(amount: float) -> bool:
	if amount <= money:
		money -= amount
		money_updated.emit()
		return true
	return false

func add_water(amount: float) -> void:
	water_tank_level = clamp(water_tank_level + amount, 0, max_water_tank_level)
	water_updated.emit()

func try_use_water(amount: float) -> float:
	var water_left: float = water_tank_level
	var water_to_use = minf(amount, water_left)
	water_tank_level -= water_to_use
	water_updated.emit()
	return water_to_use

func add_item_to_sell(item_data: ItemData) -> void:
	assert(item_data.has_component("Sell"))
	var product_slot_data: SlotData = SlotData.new()
	product_slot_data.item_data = item_data
	product_slot_data.quantity = 1
	sell_inventory_data.drop_slot_data(product_slot_data, 0)

func get_home_inventory_data(home_name: ItemData.HomeName) -> InventoryData:
	match home_name:
		ItemData.HomeName.Seed:
			return seed_inventory_data
		ItemData.HomeName.Pot:
			return pot_inventory_data
		ItemData.HomeName.Tool:
			return tool_inventory_data
		ItemData.HomeName.Shelf:
			pass
		ItemData.HomeName.Sell:
			return sell_inventory_data
		ItemData.HomeName.Buy:
			pass
	return null

func acquire_items(slot_datas: Array[SlotData]) -> void:
	for slot_data in slot_datas:
		var item_data = slot_data.item_data
		var acquire_component: AcquireComponent = item_data.get_component("Acquire")
		acquire_component.acquire(slot_data)
