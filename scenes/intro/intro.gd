extends Node

signal scene_change_requested(to)


const _SCENES := [
	preload("res://scenes/intro/000.png"),
	preload("res://scenes/intro/001.png"),
	preload("res://scenes/intro/002.png"),
	preload("res://scenes/intro/003.png"),
	preload("res://scenes/intro/004.png"),
	preload("res://scenes/intro/005.png"),
	preload("res://scenes/intro/006.png"),
	preload("res://scenes/intro/instructions.png"),
]

var _cur := -1

func _ready() -> void:
	_advance()
	


func _advance() -> void:
	_cur += 1
	if _cur == _SCENES.size():
		emit_signal("scene_change_requested", "res://scenes/overworld/overworld.tscn")
	else:
		$Scene.texture = _SCENES[_cur]


func _on_TextureButton_pressed() -> void:
	_advance()
