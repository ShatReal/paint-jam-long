extends Node


signal scene_change_requested(to)


func _ready() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.connect("start_battle", self, "_start_battle")


func _start_battle(enemies: PoolStringArray) -> void:
	emit_signal("scene_change_requested", "res://scenes/battle/battle.tscn", enemies)
