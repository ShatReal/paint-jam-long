extends Control


signal scene_change_requested(to)


func _on_start_pressed() -> void:
	emit_signal("scene_change_requested", "res://scenes/overworld/overworld.tscn")
