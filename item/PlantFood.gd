extends Resource
class_name PlantFood

@export var min_max_range: Vector2 = Vector2(0, 100)
@export var happy_range: Vector2 = Vector2(0, 100)
@export var eat_per_day: float = 0
@export var happy_fruit_factor: float = 1
@export var bad_fruit_factor: float = 0
@export var bad_days_til_death: int = 0
var curr: float
var bad_days_count: int

func in_happy_range() -> bool:
	return curr >= happy_range.x && \
		   curr <= happy_range.y

func should_die() -> bool:
	return bad_days_count >= bad_days_til_death

func fruit_factor() -> bool:
	if in_happy_range():
		return happy_fruit_factor
	else:
		return bad_fruit_factor

func next_day() -> void:
	if bad_days_til_death > 0:
		if not in_happy_range():
			bad_days_count += 1
		else:
			bad_days_count -= 1
		bad_days_count = clampi(bad_days_count, 0, bad_days_til_death)
	curr -= eat_per_day
	curr = clampf(curr, min_max_range.x, min_max_range.y)
