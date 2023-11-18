extends Slot
class_name ShelfSlot

@onready var container: Node2D = $Container
@onready var water_bar: ProgressBar = $Water/Control/WaterBar
@onready var water_low: ColorRect = $Water/Control/WaterLow
@onready var water_high: ColorRect = $Water/Control/WaterHigh
@onready var fertilizer_bar: ProgressBar = $Fertilizer/FertilizerBar
@onready var water: Node2D = $Water
@onready var fertilizer: Node2D = $Fertilizer
@onready var shelf: ColorRect = $Shelf
@onready var light_beam_back: Sprite2D = $LightBeamBack
@onready var light_beam_front: Sprite2D = $LightBeamFront
@onready var attachment: Node2D = $Attachment
@onready var attach_container: Node2D = $Attachment/Container

@export var happy_bar_stylebox_fill: StyleBoxFlat
@export var bad_bar_stylebox_fill: StyleBoxFlat
@export var happy_bar_stylebox_background: StyleBoxFlat
@export var bad_bar_stylebox_background: StyleBoxFlat

signal fruit_gathered(index: int)

func set_attachment(slot_data: SlotData) -> void:
	for child in attach_container.get_children():
		child.queue_free()
	light_beam_back.hide()
	light_beam_front.hide()
	attachment.hide()

	if slot_data:
		attachment.show()
		var item_data: ItemData = slot_data.item_data
		var node := item_data.scene.instantiate() as Node2D
		attach_container.add_child(node)
		var item_scene := node as ItemScene
		assert(item_scene)
		item_scene.set_item_data(item_data)

		var light_component: UVLightComponent = item_data.get_component("UVLight")
		if light_component:
			light_beam_back.show()
			light_beam_front.show()

func set_light(light_data: LightData) -> void:
	var base_color: Color = Color.DIM_GRAY.lerp(Color.WHITE, light_data.base_light)
	var final_color: Color = Color.DIM_GRAY.lerp(Color.WHITE, light_data.final_light)
	self_modulate = base_color
	shelf.modulate = base_color
	container.modulate = final_color

func attachment_clicked() -> void:
	var index = get_index()
	slot_clicked.emit(index, Action.AttachClick)

func fruit_clicked() -> void:
	var index = get_index()
	fruit_gathered.emit(index)

func set_slot_data(slot_data: SlotData) -> void:
	for child in container.get_children():
		child.queue_free()
	water.hide();
	fertilizer.hide();

	if not slot_data:
		tooltip_text = ""
		return

	var item_data: ItemData = slot_data.item_data
	var node := item_data.scene.instantiate() as Node2D
	container.add_child(node)
	var item_scene := node as ItemScene
	assert(item_scene)
	item_scene.set_item_data(item_data)

	var plant_component: PlantItemComponent = item_data.get_component("Plant")
	if plant_component:
		(item_scene as PlantItemScene).fruit_clicked.connect(fruit_clicked)
		var plant_data: PlantData = plant_component.plant
		if plant_data.water:
			water_bar.max_value = plant_data.water.max_val
			water_bar.value = plant_data.water.curr_val
			water_low.position.x = plant_data.water.happy_min / plant_data.water.max_val * water_bar.size.x
			water_high.position.x = plant_data.water.happy_max / plant_data.water.max_val * water_bar.size.x
			if plant_data.water.in_happy_range():
				water_bar.add_theme_stylebox_override("background", happy_bar_stylebox_background)
				water_bar.add_theme_stylebox_override("fill", happy_bar_stylebox_fill)
			else:
				water_bar.add_theme_stylebox_override("background", bad_bar_stylebox_background)
				water_bar.add_theme_stylebox_override("fill", bad_bar_stylebox_fill)
			water.show();

		if plant_data.fertilizer:
			fertilizer_bar.max_value = plant_data.fertilizer.max_val
			fertilizer_bar.value = plant_data.fertilizer.curr_val
			if plant_data.fertilizer.curr_val > 0:
				fertilizer.show();

		var compost_string: String = ""
		var compost_component: CompostComponent = item_data.get_component("Compost")
		if compost_component:
			compost_string = "Compost value: %s\n" % compost_component.get_compost_value(item_data)
		tooltip_text = "%s\n%s\n%s\n%s" % \
						[item_data.name, plant_data.get_tooltip_string(), compost_string, item_data.description]
	else:
		tooltip_text = "%s\n\n%s" % [item_data.name, item_data.description]
