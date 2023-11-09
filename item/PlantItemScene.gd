extends Node2D
class_name PlantItemScene

@onready var plant_sprite_young: Sprite2D = $PlantSpriteYoung
@onready var plant_sprite_mature: Sprite2D = $PlantSpriteMature
@onready var pot_sprite: Sprite2D = $PotSprite

func set_item_data(item_data: ItemData) -> void:
	var plant_data := item_data as PlantItemData
	assert(plant_data)
	plant_sprite_young.texture = plant_data.young_texture
	plant_sprite_mature.texture = plant_data.mature_texture
	pot_sprite.texture = plant_data.pot_item_data.rack_item_texture
	plant_sprite_young.hide()
	plant_sprite_mature.hide()
	match plant_data.growth_stage:
		PlantItemData.GrowthStage.YOUNG:
			plant_sprite_young.show()
		PlantItemData.GrowthStage.MATURE:
			plant_sprite_mature.show()
