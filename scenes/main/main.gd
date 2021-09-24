extends Node


var _cur_scene: Node
var _enemies_defeated := {
	"Bat": false,
	"Ghost": false,
	"Pumpkin": false,
	"Skull": false,
}
var _cur_fight := ""
var won := false


func _ready() -> void:
	randomize()
	call_deferred("_change_scene", "res://scenes/main_menu/main_menu.tscn")
	
	
func _change_scene(to: String, enemies := PoolStringArray()) -> void:
	if _cur_scene:
		_cur_scene.free()
	_cur_scene = load(to).instance()
	add_child(_cur_scene)
	if _cur_scene.has_signal("scene_change_requested"):
		_cur_scene.connect("scene_change_requested", self, "_change_scene", [], CONNECT_DEFERRED)
	if enemies.size() != 0:
		if enemies[0] == "res://scenes/battle/battlers/boss/boss.tscn":
			_cur_scene.set_battlers(enemies, true)
		else:
			_cur_scene.set_battlers(enemies)
		_cur_fight = enemies[0]
	match to:
		"res://scenes/main_menu/main_menu.tscn":
			$Music.stream = load("res://scenes/main_menu/PaintJamMusic2.wav")
			$Music.play()
		"res://scenes/overworld/overworld.tscn":
			if won:
				for key in _enemies_defeated:
					if key.to_lower() + "/" in _cur_fight:
						_enemies_defeated[key] = true
						break
			var all_defeated = true
			for key in _enemies_defeated:
				if _enemies_defeated[key]:
					_cur_scene.get_node("Enemies/" + key).queue_free()
				else:
					all_defeated = false
			if not $Music.stream.resource_path == "res://scenes/overworld/PaintJamMusicExploration2.wav":
				$Music.stream = load("res://scenes/overworld/PaintJamMusicExploration2.wav")
				$Music.play()
			if all_defeated:
				call_deferred("_change_scene", "res://scenes/battle/battle.tscn", PoolStringArray(["res://scenes/battle/battlers/boss/boss.tscn"]))
		"res://scenes/battle/battle.tscn":
			if "boss" in enemies[0]:
				$Music.stream = load("res://scenes/battle/PaintJam September 2021 Archifulk - Boss theme intro (not loopable).wav")
				$Music.play()
		"res://scenes/end/end.tscn":
			$Music.stream = load("res://scenes/main_menu/PaintJamMusic2.wav")
			$Music.play()


func _on_Music_finished() -> void:
	if $Music.stream.resource_path == "res://scenes/battle/PaintJam September 2021 Archifulk - Boss theme intro (not loopable).wav":
		$Music.stream = load("res://scenes/battle/PaintJam September 2021 Archifulk - Boss theme loop.wav")
	$Music.play()
