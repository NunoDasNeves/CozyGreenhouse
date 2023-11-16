extends Resource
class_name ItemType

@export var components: Array[ItemComponent]

var components_dict: Dictionary:
	get:
		if _dict.is_empty():
			for component in components:
				_dict[component.name] = component
		return _dict
	set(value):
		assert(false)
var _dict: Dictionary
