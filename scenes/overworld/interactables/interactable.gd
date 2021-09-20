extends StaticBody2D
class_name Interactable


func _ready() -> void:
	if $AnimatedSprite.frames.has_animation("idle"):
		$AnimatedSprite.play("idle")


func interact():
	pass
