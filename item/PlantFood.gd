extends Resource
class_name PlantFood

@export var max_val: float = 100
@export var happy_min: float = 0
@export var happy_max: float = 100
@export var eat_per_day: float = 0
@export var happy_fruit_factor: float = 1
@export var bad_fruit_factor: float = 0
@export var happy_growth_factor: float = 1
@export var bad_growth_factor: float = 0
@export var bad_days_til_death: int = 0
var curr_val: float
var bad_days_count: int

func in_happy_range() -> bool:
	return curr_val >= happy_min && \
		   curr_val <= happy_max

func should_die() -> bool:
	return bad_days_count >= bad_days_til_death

func fruit_factor() -> float:
	if in_happy_range():
		return happy_fruit_factor
	else:
		return bad_fruit_factor

func growth_factor() -> float:
	if in_happy_range():
		return happy_growth_factor
	else:
		return bad_growth_factor

func next_day() -> void:
	if bad_days_til_death > 0:
		if not in_happy_range():
			bad_days_count += 1
		else:
			bad_days_count -= 1
		bad_days_count = clampi(bad_days_count, 0, bad_days_til_death)
	curr_val -= eat_per_day
	curr_val = clampf(curr_val, 0, max_val)
