extends TextureRect


const _CANDIES := [
	preload("res://scenes/battle/blocks/000.png"),
	preload("res://scenes/battle/blocks/001.png"),
	preload("res://scenes/battle/blocks/002.png"),
]

var type: int
var selected := false

func _ready() -> void:
	type = randi() % _CANDIES.size()
	texture = _CANDIES[type]
	

func select(on: bool) -> void:
	selected = on
	if selected:
		modulate = Color.orangered
		$AudioStreamPlayer.play()
	else:
		modulate = Color.white
