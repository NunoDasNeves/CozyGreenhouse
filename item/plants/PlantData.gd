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

var growth_stage: GrowthStage = GrowthStage.YOUNG
var curr_fruit_growth: float = 0
var curr_growth: float = 0 # at 1, advance to next GrowthStage
var pot_item_data: ItemData
var num_fruits: int = 0
var total_fruit_produced: int = 0
var curr_growth_factor: float = 1
var curr_fruit_factor: float = 1

func get_compost_bonus() -> float:
	match growth_stage:
		GrowthStage.MATURE:
			return mature_compost_bonus
		_, GrowthStage.YOUNG:
			return 0

func get_tooltip_string() -> String:
	var string: String = ""
	if light:
		var light_happy: String = "happy"
		if light.above_happy_range():
			light_happy = "too light"
		elif light.below_happy_range():
			light_happy = "too dark"
		string += "Light:      %s (%s)\n" % [light.curr_val, light_happy]

	if water:
		var water_happy: String = "happy"
		if water.above_happy_range():
			water_happy = "overwatered"
		elif water.below_happy_range():
			water_happy = "thirsty"
		string += "Water:      %s (%s)\n" % [water.curr_val, water_happy]
	
	if fertilizer:
		string += "Fertilizer: %s" % fertilizer.curr_val

	return string

func gather_fruit() -> void:
	if fruit_item_data:
		var fruit_component: FruitComponent = fruit_item_data.get_component("Fruit")

		if fruit_component:
			for i in num_fruits:
				fruit_component.gather(fruit_item_data)

	num_fruits = 0

func next_day() -> void:
	var is_happy: bool = true
	var growth_factors: float = 1
	var fruit_factors: float = 1
	if light:
		is_happy = is_happy and light.in_happy_range()
		growth_factors *= light.growth_factor()
		fruit_factors *= light.fruit_factor()
		light.next_day()
	if water:
		is_happy = is_happy and water.in_happy_range()
		growth_factors *= water.growth_factor()
		fruit_factors *= water.fruit_factor()
		water.next_day()
	if fertilizer:
		is_happy = is_happy and fertilizer.in_happy_range()
		growth_factors *= fertilizer.growth_factor()
		fruit_factors *= fertilizer.fruit_factor()
		fertilizer.next_day()

	curr_growth_factor = growth_factors
	curr_fruit_factor = fruit_factors

	curr_growth += growth_per_day * growth_factors
	if curr_growth >= 1:
		growth_stage = GrowthStage.MATURE

	var can_make_fruit: bool = max_total_fruit_produced < 0 or total_fruit_produced < max_total_fruit_produced
	if growth_stage == GrowthStage.MATURE and can_make_fruit:
		if plant_is_fruit:
			num_fruits = max_num_fruits
			total_fruit_produced = max_total_fruit_produced
			water = null
			fertilizer = null
			light = null
		elif num_fruits < max_num_fruits:
			curr_fruit_growth += fruit_per_day * fruit_factors
			if curr_fruit_growth >= 1:
				var added_fruit: int = floori(curr_fruit_growth)
				total_fruit_produced += added_fruit
				num_fruits = clampi(num_fruits + added_fruit, 0, max_num_fruits)
				curr_fruit_growth -= added_fruit
		else:
			curr_fruit_growth = 0
