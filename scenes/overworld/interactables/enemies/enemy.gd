extends Interactable


signal start_battle(enemies)

export(PoolStringArray) var _enemies: PoolStringArray


func interact() -> void:
	emit_signal("start_battle", _enemies)

