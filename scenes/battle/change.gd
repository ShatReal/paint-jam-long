extends Label



func _ready() -> void:
	$AnimationPlayer.play("fade")


func _on_fade_complete():
	queue_free()
