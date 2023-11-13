extends Node

var curr_day: int = 0
var water_tank_level: float = 10
var max_water_tank_level: float = 25
var money: float = 10

func _process(delta: float) -> void:
	pass

func next_day() -> void:
	curr_day += 1

func try_use_water(amount: float) -> float:
	var water_left: float = Global.water_tank_level
	var water_to_use = minf(amount, water_left)
	water_tank_level -= water_to_use
	return water_to_use
