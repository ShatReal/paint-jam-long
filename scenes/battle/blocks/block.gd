extends TextureRect


const _CANDIES := [
	preload("res://scenes/battle/blocks/candy_0.png"),
	preload("res://scenes/battle/blocks/candy_1.png"),
	preload("res://scenes/battle/blocks/candy_2.png"),
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
	else:
		modulate = Color.white
