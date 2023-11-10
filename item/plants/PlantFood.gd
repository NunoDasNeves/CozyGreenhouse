extends Resource
class_name PlantFood

@export var min_max_range: Vector2 = Vector2(0, 100)
@export var happy_range: Vector2 = Vector2(0, 100)
@export var eat_per_day: float = 0
@export var happy_fruit_factor: float = 1
@export var bad_fruit_factor: float = 0
@export var bad_days_til_death: int = -1
var curr: float
var bad_days_count: int
