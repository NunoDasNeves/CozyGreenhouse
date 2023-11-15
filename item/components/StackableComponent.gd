extends ItemComponent
class_name StackableComponent

@export var max_stack_size: int = 99
@export var show_1x_quantity: bool = true

static func get_component_name() -> StringName:
	return "Stackable"
