extends Node


signal scene_change_requested(to)

onready var _player := $YSort/Witch


func _ready() -> void:
	for object in get_tree().get_nodes_in_group("object"):
		object.connect("show_dialogue", self, "_show_dialogue")
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.connect("start_battle", self, "_start_battle")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and $UI/Dialogue.visible:
		get_tree().set_input_as_handled()
		$UI/Dialogue.hide()
		_player.can_move = true


func _show_dialogue(dialogue: String) -> void:
	$UI/Dialogue.show()
	$UI/Dialogue/HBox/Dialogue.bbcode_text = dialogue


func _start_battle(enemies: PoolStringArray) -> void:
	emit_signal("scene_change_requested", "res://scenes/battle/battle.tscn", enemies)
