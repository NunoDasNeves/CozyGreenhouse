extends Control
class_name InventoryInterface

@onready var next_day_button: Button = $NextDayButton
@onready var grab_slot: GrabSlot = $GrabSlot
@onready var day_num: Label = $DayNum
@onready var water_tank_bar: ProgressBar = $WaterTankBar
@onready var money_amount: Label = $MoneyAmount
@onready var compost_bar: ProgressBar = $Compost/ProgressBar
@onready var compost_button: CompostBin = $Compost/TextureButton
@onready var merchant: Node2D = $MerchantContainer/Merchant
@onready var merchant_sprite: Sprite2D = $MerchantContainer/Merchant/background/Sprite

@onready var seed_inventory: Inventory = $SeedInventory
@onready var pots_inventory: Inventory = $PotsInventory
@onready var tools_inventory: Inventory = $ToolsInventory
@onready var shelf_inventory: Inventory = $ShelfInventory
@onready var sell_inventory: Inventory = $TabContainer/Inventory
@onready var buy_inventory: Inventory = $TabContainer/Shop

@export var initial_state: State
@export var debug_state: State

var state: State

func ready_inventory(inventory: Inventory) -> void:
	if inventory.inventory_interact.is_connected(grab_slot.on_inventory_interact):
		inventory.inventory_interact.disconnect(grab_slot.on_inventory_interact)
	inventory.inventory_interact.connect(grab_slot.on_inventory_interact)

func _ready() -> void:
	ready_inventory(seed_inventory)
	ready_inventory(pots_inventory)
	ready_inventory(tools_inventory)
	ready_inventory(shelf_inventory)
	ready_inventory(sell_inventory)
	ready_inventory(buy_inventory)

	compost_button.composted_grabbed_item.connect(clear_grab_slot)
	next_day_button.button_down.connect(next_day)

	init_initial_state()

func init_initial_state() -> void:
	init_game_state(initial_state.duplicate())

func init_debug_state() -> void:
	init_game_state(debug_state.duplicate())

func init_game_state(the_state: State) -> void:
	Global.state = the_state.duplicate()
	state = Global.state
	state.init_curr_day()

	state.water_updated.connect(update_water_tank)
	state.money_updated.connect(update_money_text)
	state.compost_updated.connect(update_compost_bar)
	state.shop_updated.connect(update_shop)

	grab_slot.grab_data = state.grab_data
	grab_slot.update()

	seed_inventory.init(state.seed_inventory_data)
	pots_inventory.init(state.pot_inventory_data)
	tools_inventory.init(state.tool_inventory_data)
	shelf_inventory.init(state.shelf_inventory_data)
	sell_inventory.init(state.sell_inventory_data)

	update_water_tank()
	update_money_text()
	update_compost_bar()
	update_shop()

func _input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
		if grab_slot.dismiss():
			accept_event()
			return
	var key_event := event as InputEventKey
	if key_event and key_event.is_pressed():
		if key_event.keycode == KEY_R:
			init_initial_state()
		elif key_event.keycode == KEY_D:
			init_debug_state()

func clear_grab_slot() -> void:
	grab_slot.clear()

func update_compost_bar() -> void:
	compost_bar.max_value = Global.state.COMPOST_MAX
	compost_bar.value = Global.state.compost

func init_merchant(merchant_data: MerchantData) -> void:
	if merchant_data:
		merchant_sprite.texture = merchant_data.texture
		merchant.show()
	else:
		merchant.hide()

func update_shop() -> void:
	var buy_inventory_data: ProductInventoryData = state.buy_inventory_data
	if buy_inventory_data != buy_inventory.inventory_data:
		buy_inventory.init(state.buy_inventory_data)
	var merchant_data: MerchantData = state.curr_merchant
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
