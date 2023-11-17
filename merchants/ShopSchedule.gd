extends Resource
class_name ShopSchedule

@export var initial_days: Array[MerchantData]
@export var random_merchant_pool: Array[MerchantData]

func get_todays_merchant(day: int) -> MerchantData:
	if day < initial_days.size():
		return initial_days[day]
	if random_merchant_pool.size():
		return random_merchant_pool[randi_range(0, random_merchant_pool.size() - 1)]
	return null
