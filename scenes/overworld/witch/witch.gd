extends KinematicBody2D


const _SPEED := 100

var _velocity := Vector2()
var can_move := true


func _physics_process(_delta: float) -> void:
	if can_move:
		var input := Vector2()
		input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
		input = input.normalized()
		
		_velocity = move_and_slide(input * _SPEED)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for area in $Interactor.get_overlapping_areas():
			if area.get_parent().has_method("interact"):
				area.get_parent().interact()
				can_move = false
				break
