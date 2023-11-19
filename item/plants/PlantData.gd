extends Resource
class_name PlantData

enum GrowthStage {
	YOUNG,
	MATURE,
}

@export var young_texture: Texture
@export var mature_texture: Texture
@export var light: PlantFood
@export var water: PlantFood
@export var fertilizer: PlantFood
@export var fruit_per_day: float
@export var growth_per_day: float
@export var max_num_fruits: int
@export var fruit_item_data: ItemData
@export var mature_compost_bonus: float = 4
@export var max_total_fruit_produced: int = -1 # -1 means infinite
@export var plant_is_fruit: bool
@export var emit_light: bool = false

var growth_stage: GrowthStage = GrowthStage.YOUNG
var curr_fruit_growth: float = 0
var curr_growth: float = 0 # at 1, advance to next GrowthStage
var pot_item_data: ItemData
var num_fruits: int = 0
var total_fruit_produced: int = 0

func get_compost_bonus() -> float:
	match growth_stage:
		GrowthStage.MATURE:
			return mature_compost_bonus
		_, GrowthStage.YOUNG:
			return 0

func get_tooltip_string() -> String:
	var string: String = ""
	if growth_stage == GrowthStage.MATURE:
		if plant_is_fruit or num_fruits:
			string = "[ Ready to pick! ]\n"
		else:
			string = "[ Growth stage: Mature ]\n"
	else:
		string = "[ Growth stage: Young ]\n"

	if growth_stage == GrowthStage.MATURE:
		if not plant_is_fruit:
			string += "Fruit factor: %s\n" % get_fruit_factor()
	else:
		string += "Growth factor: %s\n" % get_growth_factor()

	if light:
		var light_happy: String = "happy"
		if light.above_happy_range():
			light_happy = "too light"
		elif light.below_happy_range():
			light_happy = "too dark"
		string += "Light: %s\n" % light_happy

	if water:
		var water_happy: String = "happy"
		if water.above_happy_range():
			water_happy = "overwatered"
		elif water.below_happy_range():
			water_happy = "thirsty"
		string += "Water: %s\n" % water_happy

	if fertilizer:
		var val: float = 0
		if fertilizer.curr_val > 0:
			if growth_stage == GrowthStage.MATURE:
				if not plant_is_fruit:
					val = fertilizer.fruit_factor()
			else:
				val = fertilizer.growth_factor()
		string += "Fertilizer bonus: %s\n" % val

	return string

func gather_fruit() -> void:
	if fruit_item_data:
		var fruit_component: FruitComponent = fruit_item_data.get_component("Fruit")

		if fruit_component:
			for i in num_fruits:
				fruit_component.gather(fruit_item_data)

	num_fruits = 0

func get_fruit_factor() -> float:
	var fruit_factor: float = 1
	if light:
		fruit_factor *= light.fruit_factor()
	if water:
		fruit_factor *= water.fruit_factor()
	if fertilizer:
		fruit_factor *= fertilizer.fruit_factor()
	return fruit_factor

func get_growth_factor() -> float:
	var growth_factor: float = 1
	if light:
		growth_factor *= light.growth_factor()
	if water:
		growth_factor *= water.growth_factor()
	if fertilizer:
		growth_factor *= fertilizer.growth_factor()
	return growth_factor

func get_happy() -> bool:
	var is_happy: bool = true
	if light:
		is_happy = is_happy and light.in_happy_range()
	if water:
		is_happy = is_happy and water.in_happy_range()
	if fertilizer:
		is_happy = is_happy and fertilizer.in_happy_range()

	return is_happy

func next_day() -> void:

	var growth_factor: float = get_growth_factor()
	var fruit_factor: float = get_fruit_factor()

	var can_make_fruit: bool = max_total_fruit_produced < 0 or total_fruit_produced < max_total_fruit_produced
	if growth_stage == GrowthStage.MATURE and can_make_fruit:
		if num_fruits < max_num_fruits:
			curr_fruit_growth += fruit_per_day * fruit_factor
			if curr_fruit_growth >= 1:
				var added_fruit: int = floori(curr_fruit_growth)
				total_fruit_produced += added_fruit
				num_fruits = clampi(num_fruits + added_fruit, 0, max_num_fruits)
				curr_fruit_growth -= added_fruit
		else:
			curr_fruit_growth = 0

	curr_growth += growth_per_day * growth_factor
	if curr_growth >= 1:
		growth_stage = GrowthStage.MATURE

	if growth_stage == GrowthStage.MATURE and plant_is_fruit:
		num_fruits = max_num_fruits
		total_fruit_produced = max_total_fruit_produced
		water = null
		fertilizer = null
		light = null

	if light:
		light.next_day()
	if water:
		water.next_day()
	if fertilizer:
		fertilizer.next_day()
