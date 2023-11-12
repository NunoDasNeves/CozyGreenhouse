extends ItemScene
class_name WateringCanScene

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
var animating_forward: bool = true

func _ready() -> void:
	animated_sprite.animation_finished.connect(anim_finished)

func set_item_data(item_data: ItemData) -> void:
	pass

func anim_finished():
	if animating_forward:
		animated_sprite.play_backwards()
		animating_forward = false

func play_anim() -> void:
	animated_sprite.play()
	animating_forward = true

