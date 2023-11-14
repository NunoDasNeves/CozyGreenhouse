extends Control
class_name InventoryInterface

@onready var next_day_button: Button = $NextDayButton
@onready var grab_slot: GrabSlot = $GrabSlot
@onready var day_num: Label = $DayNum
@onready var water_tank_bar: ProgressBar = $WaterTankBar
@onready var money_amount: Label = $MoneyAmount

@onready var seed_inventory: PanelContainer = $SeedInventory
@onready var pots_inventory: PanelContainer = $PotsInventory
@onready var tools_inventory: PanelContainer = $ToolsInventory
@onready var shelf_inventory: PanelContainer = $ShelfInventory
@onready var sell_inventory: PanelContainer = $SellInventory
@onready var buy_inventory: PanelContainer = $BuyInventory

@export var initial_state: State
var state: State

func init_inventory(inventory: Inventory, inventory_data: InventoryData):
	inventory.init(inventory_data)
	inventory.inventory_interact.connect(grab_slot.on_inventory_interact)
	inventory.inventory_data.water_tank_level_updated.connect(update_water_tank)
	inventory.inventory_data.money_updated.connect(update_money_text)

func _ready() -> void:
	Global.state = initial_state.duplicate()
	state = Global.state

	grab_slot.grab_data = state.grab_data
	grab_slot.update()

	init_inventory(seed_inventory, state.seed_inventory_data)
	init_inventory(pots_inventory, state.pot_inventory_data)
	init_inventory(tools_inventory, state.tool_inventory_data)
	init_inventory(shelf_inventory, state.shelf_inventory_data)
	init_inventory(sell_inventory, state.sell_inventory_data)
	init_inventory(buy_inventory, state.buy_inventory_data)

	next_day_button.button_down.connect(next_day)
	update_water_tank()
	update_money_text()

func _input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
		if grab_slot.dismiss():
			accept_event()

func update_water_tank() -> void:
	var old_water_level: float = water_tank_bar.value
	water_tank_bar.max_value = state.max_water_tank_level
	water_tank_bar.value = state.water_tank_level
	if old_water_level > 0:
		var grab_scene: Node2D = grab_slot.get_child(0)
		if grab_scene and grab_scene is WateringCanScene:
			(grab_scene as WateringCanScene).play_anim()

func update_money_text() -> void:
	money_amount.text = "Money: $%s" % state.money

func next_day() -> void:
	state.next_day()
	grab_slot.update()
	day_num.text = "Day: %s" % state.curr_day
