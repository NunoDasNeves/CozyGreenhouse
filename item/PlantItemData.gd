extends ShelfItemData
class_name PlantItemData

enum GrowthStage {
	YOUNG,
	MATURE,
}

@export var young_texture: Texture
@export var mature_texture: Texture
@export var light: PlantFood
@export var water: PlantFood
@export var fertilizer: PlantFood
@export var happy_fruit_per_day: float
@export var happy_growth_per_day: float

var growth_stage: GrowthStage = GrowthStage.YOUNG
var curr_growth: float = 0 # at 1, advance to next GrowthStage
var pot_item_data: RackItemData

static func create_from_seed(seed_data: SeedItemData, pot_data: RackItemData) -> PlantItemData:
	var plant_data : PlantItemData = seed_data.plant.duplicate()
	plant_data.pot_item_data = pot_data
	return plant_data
