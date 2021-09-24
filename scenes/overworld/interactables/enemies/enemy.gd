extends Interactable


signal start_battle(enemies)

const _BOUNDS := Vector2(480, 270)

export(PoolStringArray) var _enemies: PoolStringArray
export(int) var speed := 100

var dest := Vector2(randi()%int(_BOUNDS.x), randi()%int(_BOUNDS.y))


func _physics_process(delta: float) -> void:
	var dir := position.direction_to(dest)
	if speed * delta > position.distance_to(dest):
		position = dest
		dest = Vector2(randi()%int(_BOUNDS.x), randi()%int(_BOUNDS.y))
	else:
		position += dir * speed * delta
	if dir.x > 0.5:
		$AnimatedSprite.play("right")
	elif dir.x < -0.5:
		$AnimatedSprite.play("left")
	elif dir.y > 0.5:
		$AnimatedSprite.play("down")
	elif dir.y < -0.5:
		$AnimatedSprite.play("up")


func interact() -> void:
	emit_signal("start_battle", _enemies)

