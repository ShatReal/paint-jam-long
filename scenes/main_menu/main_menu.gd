extends Control


signal scene_change_requested(to)


func _on_start_pressed() -> void:
	emit_signal("scene_change_requested", "res://scenes/intro/intro.tscn")


func _on_RichTextLabel_meta_clicked(meta) -> void:
	OS.shell_open(meta)


func _on_Credits_pressed() -> void:
	$PopupPanel.popup_centered()
