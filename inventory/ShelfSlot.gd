extends Slot
class_name ShelfSlot

@onready var pot_texture_rect: TextureRect = $MarginContainer/PotTextureRect
@onready var plant_texture_rect: TextureRect = $MarginContainer2/PlantTextureRect

func set_slot_data(slot_data: SlotData) -> void:
	if not slot_data:
		pot_texture_rect.texture = null
		plant_texture_rect.texture = null
		tooltip_text = ""
		return
	var shelf_item_data = slot_data.item_data as ShelfItemData
	assert(shelf_item_data)
	match shelf_item_data.type:
		ItemData.Type.POT:
			pot_texture_rect.texture = shelf_item_data.texture
			plant_texture_rect.texture = null
			tooltip_text = ""
		ItemData.Type.PLANT:
			var plant_item_data = slot_data.item_data as PlantItemData
			assert(plant_item_data)
			pot_texture_rect.texture = plant_item_data.pot_item_data.texture
			plant_texture_rect.texture = plant_item_data.young_texture
			tooltip_text = "%s\n%s" % [plant_item_data.name, plant_item_data.description]

