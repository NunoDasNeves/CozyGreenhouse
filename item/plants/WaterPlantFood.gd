extends PlantFood
class_name WaterPlantFood

@export var over_water_growth_factor: float = 0.8
@export var under_water_growth_factor: float = 0

func fruit_factor() -> float:
	if below_happy_range():
		return under_water_growth_factor * bad_fruit_factor
	if above_happy_range():
		return over_water_growth_factor * bad_fruit_factor
	return happy_fruit_factor

func growth_factor() -> float:
	if below_happy_range():
		return under_water_growth_factor * bad_growth_factor
	if above_happy_range():
		return over_water_growth_factor * bad_growth_factor
	return happy_growth_factor
