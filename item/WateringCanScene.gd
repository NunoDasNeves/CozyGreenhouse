extends Node2D
class_name WateringCanScene

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
var do_animate: bool = false

func set_item_data(item_data: ItemData) -> void:
	pass

func anim_finished_backward():
	animated_sprite.animation_finished.disconnect(anim_finished_backward)

func anim_finished_forward():
	animated_sprite.animation_finished.disconnect(anim_finished_forward)
	animated_sprite.animation_finished.connect(anim_finished_backward)
	animated_sprite.play_backwards()

func play_anim() -> void:
	animated_sprite.animation_finished.connect(anim_finished_forward)
	animated_sprite.play()#do_animate = true

#func _process(delta: float) -> void:
	#if do_animate:
		#animated_sprite.play()
