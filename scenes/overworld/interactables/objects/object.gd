extends Interactable


signal show_dialogue(dialogue)

export(String, MULTILINE) var _dialogue: String


func interact() -> void:
	emit_signal("show_dialogue", _dialogue)
