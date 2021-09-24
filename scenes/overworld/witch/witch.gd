extends KinematicBody2D


const _SPEED := 100

var _velocity := Vector2()


func _physics_process(_delta: float) -> void:
	var input := Vector2()
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	if input.x == 1:
		$AnimatedSprite.play("right")
	elif input.x == -1:
		$AnimatedSprite.play("left")
	elif input.y == 1:
		$AnimatedSprite.play("down")
	elif input.y == -1:
		$AnimatedSprite.play("up")
	else:
		$AnimatedSprite.stop()
	input = input.normalized()
	
	_velocity = move_and_slide(input * _SPEED)

	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for area in $Interactor.get_overlapping_areas():
			if area.get_parent().has_method("interact"):
				area.get_parent().interact()
				break
