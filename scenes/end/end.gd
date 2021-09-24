extends TextureRect



func _on_Credits_pressed() -> void:
	$PopupPanel.popup_centered()


func _on_RichTextLabel_meta_clicked(meta) -> void:
	OS.shell_open(meta)
