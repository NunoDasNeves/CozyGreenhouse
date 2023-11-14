extends Control
class_name InventoryInterface

@onready var next_day_button: Button = $NextDayButton
@onready var grab_slot: GrabSlot = $GrabSlot
@onready var day_num: Label = $DayNum
@onready var water_tank_bar: ProgressBar = $WaterTankBar
@onready var money_amount: Label = $MoneyAmount

@export var inventories: Array[Inventory]

func _ready() -> void:
	for inventory in inventories:
		inventory.inventory_interact.connect(grab_slot.on_inventory_interact)
		inventory.inventory_data.water_tank_level_updated.connect(update_water_tank)
		inventory.inventory_data.money_updated.connect(update_money_text)
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
	water_tank_bar.max_value = Global.max_water_tank_level
	water_tank_bar.value = Global.water_tank_level
	if old_water_level > 0:
		var grab_scene: Node2D = grab_slot.get_child(0)
		if grab_scene and grab_scene is WateringCanScene:
			(grab_scene as WateringCanScene).play_anim()

func update_money_text() -> void:
	money_amount.text = "Money: $%s" % Global.money

func next_day() -> void:
	Global.next_day()
	day_num.text = "Day: %s" % Global.curr_day
	for inventory in inventories:
		inventory.inventory_data.next_day()
