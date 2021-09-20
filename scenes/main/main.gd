extends Node


var _cur_scene: Node


func _ready() -> void:
	call_deferred("_change_scene", "res://scenes/main_menu/main_menu.tscn")
	
	
func _change_scene(to: String, enemies := PoolStringArray()) -> void:
	if _cur_scene:
		_cur_scene.free()
	_cur_scene = load(to).instance()
	add_child(_cur_scene)
	if _cur_scene.has_signal("scene_change_requested"):
		_cur_scene.connect("scene_change_requested", self, "_change_scene", [], CONNECT_DEFERRED)
	if enemies.size() != 0:
		_cur_scene.set_battlers(enemies)
