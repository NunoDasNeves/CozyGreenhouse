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

var growth_stage: GrowthStage = GrowthStage.YOUNG
var curr_fruit_growth: float = 0
var curr_growth: float = 0 # at 1, advance to next GrowthStage
var pot_item_data: ItemData
var num_fruits: int = 0

func get_compost_bonus() -> float:
	match growth_stage:
		GrowthStage.MATURE:
			return mature_compost_bonus
		_, GrowthStage.YOUNG:
			return 0

func get_tooltip_string() -> String:
	var light_happy: String = "happy"
	var water_happy: String = "happy"

	if light.above_happy_range():
		light_happy = "too light"
	elif light.below_happy_range():
		light_happy = "too dark"

	if not water.in_happy_range():
		if water.curr_val == 0:
			water_happy = "no growth!"
		elif water.above_happy_range():
			water_happy = "overwatered"
		elif water.below_happy_range():
			water_happy = "thirsty"

	return "Light:      %s (%s)\nWater:      %s (%s)\nFertilizer: %s" % \
			[light.curr_val, light_happy, water.curr_val, water_happy, fertilizer.curr_val]

func gather_fruit() -> void:
	if fruit_item_data:
		var fruit_component: FruitComponent = fruit_item_data.get_component("Fruit")

		if fruit_component:
			for i in num_fruits:
				fruit_component.gather(fruit_item_data)

	num_fruits = 0

func next_day() -> void:
	light.next_day()
	water.next_day()
	fertilizer.next_day()
	var is_happy: bool = light.in_happy_range() and \
						 water.in_happy_range() and \
						 fertilizer.in_happy_range()
	var growth_factors: float = light.growth_factor() * water.growth_factor() * fertilizer.growth_factor()
	var fruit_factors: float = light.fruit_factor() * water.fruit_factor() * fertilizer.fruit_factor()

	curr_growth += growth_per_day * growth_factors
	if curr_growth >= 1:
		growth_stage = GrowthStage.MATURE
	if num_fruits < max_num_fruits:
		curr_fruit_growth += fruit_per_day * fruit_factors
		if curr_fruit_growth >= 1:
			var added_fruit: int = floori(curr_fruit_growth)
			num_fruits = clampi(num_fruits + added_fruit, 0, max_num_fruits)
			curr_fruit_growth -= added_fruit
	else:
		curr_fruit_growth = 0
