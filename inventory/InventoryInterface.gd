extends Control
class_name InventoryInterface

@onready var next_day_button: Button = $NextDayButton
@onready var grab_slot: GrabSlot = $GrabSlot
@onready var day_num: Label = $DayNum
@onready var water_tank_bar: ProgressBar = $WaterTankBar
@onready var money_amount: Label = $MoneyAmount
@onready var compost_bar: ProgressBar = $Compost/ProgressBar
@onready var compost_button: CompostBin = $Compost/TextureButton

@onready var seed_inventory: PanelContainer = $SeedInventory
@onready var pots_inventory: PanelContainer = $PotsInventory
@onready var tools_inventory: PanelContainer = $ToolsInventory
@onready var shelf_inventory: PanelContainer = $ShelfInventory
@onready var sell_inventory: PanelContainer = $TabContainer/Inventory
@onready var buy_inventory: PanelContainer = $TabContainer/Shop

@export var initial_state: State
var state: State

func init_inventory(inventory: Inventory, inventory_data: InventoryData):
	inventory.init(inventory_data)
	inventory.inventory_interact.connect(grab_slot.on_inventory_interact)

func init() -> void:
	Global.state = initial_state.duplicate()
	state = Global.state
	state.init_curr_day()

	state.water_updated.connect(update_water_tank)
	state.money_updated.connect(update_money_text)
	state.compost_updated.connect(update_compost_bar)
	state.shop_updated.connect(update_shop)

	grab_slot.grab_data = state.grab_data
	grab_slot.update()

	init_inventory(seed_inventory, state.seed_inventory_data)
	init_inventory(pots_inventory, state.pot_inventory_data)
	init_inventory(tools_inventory, state.tool_inventory_data)
	init_inventory(shelf_inventory, state.shelf_inventory_data)
	init_inventory(sell_inventory, state.sell_inventory_data)

	compost_button.composted_grabbed_item.connect(clear_grab_slot)
	next_day_button.button_down.connect(next_day)
	update_water_tank()
	update_money_text()
	update_compost_bar()
	update_shop()

func _ready() -> void:
	init()

func _input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
		if grab_slot.dismiss():
			accept_event()

func clear_grab_slot() -> void:
	grab_slot.clear()

func update_compost_bar() -> void:
	compost_bar.max_value = Global.state.COMPOST_MAX
	compost_bar.value = Global.state.compost

func init_merchant(merchant_data: MerchantData) -> void:
	pass

func update_shop() -> void:
	var buy_inventory_data: ProductInventoryData = state.buy_inventory_data
	if buy_inventory_data:
		init_inventory(buy_inventory, buy_inventory_data)
	var merchant_data: MerchantData = state.curr_merchant
	if merchant_data:
		init_merchant(merchant_data)

func update_water_tank() -> void:
	var old_water_level: float = water_tank_bar.value
	water_tank_bar.max_value = state.max_water_tank_level
	water_tank_bar.value = state.water_tank_level
	if old_water_level > 0:
		var grab_scene: Node2D = grab_slot.container.get_child(0)
		if grab_scene and grab_scene is WateringCanScene:
			(grab_scene as WateringCanScene).play_anim()

func update_money_text() -> void:
	money_amount.text = "Money: $%s" % state.money

func next_day() -> void:
	state.next_day()
	update_water_tank()
	update_money_text()
	grab_slot.update()
	day_num.text = "Day: %s" % state.curr_day
