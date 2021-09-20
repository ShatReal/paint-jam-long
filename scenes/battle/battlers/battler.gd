extends AnimatedSprite


signal target_selected(this)
signal died(this)

const _HEALTH_TEXT := "%d / %d"

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
	change_health(0)


# Negative values are damage and positive values are heal
func change_health(amt: int) -> void:
# warning-ignore:narrowing_conversion
	health = clamp(health + amt, 0, max_health)
	_health_bar.value = health
	_health_label.text = _HEALTH_TEXT % [health, max_health]
	if health == 0:
		emit_signal("died", self)


func set_target() -> void:
	$Target.pressed = true


func _on_target_pressed() -> void:
	emit_signal("target_selected", self)
