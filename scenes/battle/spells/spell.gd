extends AnimatedSprite


signal tween_all_completed


func cast(i: int, start: Vector2, end: Vector2, time: float) -> void:
	play(str(i))
	$Tween.interpolate_property(
		self,
		"global_position",
		start,
		end,
		time
	)
	$Tween.start()


func _on_Tween_tween_all_completed() -> void:
	emit_signal("tween_all_completed")
	queue_free()
