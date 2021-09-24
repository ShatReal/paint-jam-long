extends AnimatedSprite


signal target_selected(this)
signal anim_finished

const _HEALTH_TEXT := "%d / %d"
const _CHANGE_OFFSET := Vector2(-30, -140)

const _Change := preload("res://scenes/battle/change.tscn")

export(int, 1, 2_147_483_647) var max_health := 1
export(int, 0, 2_147_483_647) var health := 1
export(int, 0, 2_147_483_647) var attack := 1
export(int, 0, 2_147_483_647) var defense := 0
export(PoolIntArray) var skills: PoolIntArray

onready var _health_bar := $HealthBar
onready var _health_label := $HealthBar/HealthLabel


func _ready() -> void:
	if frames and frames.has_animation("idle"):
		play("idle")
	_health_bar.max_value = max_health
	_health_bar.value = health
	_health_label.text = _HEALTH_TEXT % [health, max_health]


# Negative values are damage and positive values are heal
func change_health(amt: int) -> void:
# warning-ignore:narrowing_conversion
	health = clamp(health + amt, 0, max_health)
	_health_bar.value = health
	_health_label.text = _HEALTH_TEXT % [health, max_health]
	if health == 0:
		$AnimationPlayer.play("damage")
		if frames.has_animation("die"):
			play("die")
	else:
		if amt < 0:
			$AnimationPlayer.play("damage")
			$Damage.play()
		elif amt > 0:
			$AnimationPlayer.play("heal")
			$Heal.play()
	var change := _Change.instance()
	change.text = str(amt)
	add_child(change)
	change.rect_position = _CHANGE_OFFSET


func set_target() -> void:
	$Target.pressed = true


func _on_target_pressed() -> void:
	emit_signal("target_selected", self)


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	emit_signal("anim_finished")
