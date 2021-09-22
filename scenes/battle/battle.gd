extends Node


signal scene_change_requested(to)

enum {
	WAIT,
	PLAYER,
	ENEMY,
	OVER,
}

const _NUM_COLS := 16
const _NUM_ROWS := 2

const _Block := preload("res://scenes/battle/blocks/block.tscn")
const _Change := preload("res://scenes/battle/change.tscn")
const _Spell := preload("res://scenes/battle/spells/spell.tscn")

var _state: int
var _selected_blocks := []
var _drag_cancelled := false
var _spell_queue := []
var _enemies := []
var _player: AnimatedSprite
var _target := 4
var _won := false

onready var _grid := $Panel/MarginContainer/GridContainer


func _ready() -> void:
	randomize()
	
	_grid.columns = _NUM_COLS
	for y in _NUM_ROWS:
		var row = []
		for x in _NUM_COLS:
			var t := _Block.instance()
			_grid.add_child(t)
			row.append(false)
	
	for sprite in $Battlers.get_children():
		if sprite.name == "Witch":
			_player = sprite
		else:
			_enemies.append(sprite)
	
	_change_state(WAIT)
	

func _input(event: InputEvent) -> void:
	if _state == OVER:
		return
	if (event is InputEventMouseMotion and Input.is_action_pressed("click")\
	or event.is_action_pressed("click")) and not _drag_cancelled:
		if _grid.get_global_rect().has_point(event.position):
			var col: int = (event.position.x - _grid.rect_global_position.x) / (_grid.rect_size.x / _NUM_COLS)
			var row: int = (event.position.y - _grid.rect_global_position.y) / (_grid.rect_size.y / _NUM_ROWS)
			var block := _grid.get_child(row * _NUM_COLS + col)
			if not block.selected:
				if _selected_blocks.size() == 0:
					block.select(true)
					_selected_blocks.append(block)
				elif _selected_blocks[0].type == block.type:
					var is_neighbor := false
					for other_block in _selected_blocks:
						var dif: int = other_block.get_index() - block.get_index()
						if abs(dif) == 1 or abs(dif) == _NUM_COLS:
							is_neighbor = true
							break
					if is_neighbor:
						block.select(true)
						_selected_blocks.append(block)
	elif event.is_action_released("click"):
		if _selected_blocks.size() == 1:
			_spell_queue.append([_selected_blocks[0].type, 0])
			_replace_blocks()
		elif _selected_blocks.size() == 2:
			_spell_queue.append([_selected_blocks[0].type, 1])
			_replace_blocks()
		elif _check_for_square():
			_spell_queue.append([_selected_blocks[0].type, 2])
			_replace_blocks()
		for block in _grid.get_children():
			if block.selected:
				block.select(false)
		_selected_blocks = []
		_drag_cancelled = false
	elif (event.is_action_pressed("ui_cancel")\
	or event.is_action_pressed("right_click"))\
	and Input.is_action_pressed("click"):
		_drag_cancelled = true
		for block in _grid.get_children():
			if block.selected:
				block.select(false)
		_selected_blocks = []
		

func set_battlers(enemies: PoolStringArray) -> void:
	var bg := ButtonGroup.new()
	for i in enemies.size():
		var e: AnimatedSprite = load(enemies[i]).instance()
		$Battlers.add_child(e)
		e.position = $Battlers.get_child(i).position
		e.connect("target_selected", self, "_on_target_selected")
		e.connect("died", self, "_on_battler_died")
		e.get_node("Target").group = bg
	if $Battlers.get_child_count() > 4:
		$Battlers.get_child(_target).set_target()
		

func _on_target_selected(target: AnimatedSprite) -> void:
	_target = target.get_index()
	
	
func _on_battler_died(battler: AnimatedSprite) -> void:
	if battler.name == "Witch":
		_change_state(OVER)
	else:
		battler.queue_free()
		if $Battlers.get_child_count() == 5:
			_won = true
			_change_state(OVER)
		else:
# warning-ignore:narrowing_conversion
			yield(get_tree(), "idle_frame")
			_target = clamp(_target, 4, $Battlers.get_child_count())
			$Battlers.get_child(_target).set_target()
	

func _get_block_coords(block: TextureRect) -> Vector2:
# warning-ignore:integer_division
	return Vector2(block.get_index() % _NUM_COLS, block.get_index() / _NUM_COLS)


func _check_for_square() -> bool:
	if _selected_blocks.size() == 4:
		var first_square: TextureRect
		var pos_0 := _get_block_coords(_selected_blocks[0])
		for i in range(1, 4):
			if (_get_block_coords(_selected_blocks[i]) - pos_0).abs() == Vector2(1, 1):
				first_square = _selected_blocks[i]
				break
		if first_square:
			var second_square: TextureRect
			var pos_1 = _get_block_coords(first_square)
			for i in range(1, 4):
				var pos := _get_block_coords(_selected_blocks[i])
				if pos.x == pos_0.x and pos.y == pos_1.y:
					second_square = _selected_blocks[i]
					break
			if second_square:
				var third_square: TextureRect
				for i in range(1, 4):
					var pos := _get_block_coords(_selected_blocks[i])
					if pos.x == pos_1.x and pos.y == pos_0.y:
						third_square = _selected_blocks[i]
						break
				if third_square:
					return true
				else:
					return false
			else:
				return false
		else:
			return false
	else:
		return false
		

func _replace_blocks() -> void:
	$BlockMatch.play()
	var total_free_top := 0
	var total_free_bottom := 0
	for block in _selected_blocks:
		if block.get_index() < _NUM_COLS:
			total_free_top += 1
		else:
			total_free_bottom += 1
		block.queue_free()
	for i in total_free_top:
		var b := _Block.instance()
		_grid.add_child(b)
		_grid.move_child(b, _NUM_COLS - 1)
	for i in total_free_bottom:
		var b := _Block.instance()
		_grid.add_child(b)
	if _state == WAIT:
		_change_state(PLAYER)


func _change_state(new_state) -> void:
	_state = new_state
	match _state:
		WAIT:
			pass
		PLAYER:
			$SpellShoot.play()
#			if _spell_queue[0][0] == 2:
#				_player.change_health(_player.skills[_spell_queue[0][0] * 3 +\
#				_spell_queue[0][1]] * _player.attack)
#				var change := _Change.instance()
#				change.text = str(_player.skills[_spell_queue[0][0] * 3 +\
#				_spell_queue[0][1]] * _player.attack)
#				add_child(change)
#				change.rect_global_position = _player.global_position - Vector2(0, 100)
#				yield(_player, "anim_finished")
#			else:
			if _target >= $Battlers.get_child_count():
				return
			$Battlers.get_child(_target).change_health(_player.skills\
			[_spell_queue[0][0] * 3 + _spell_queue[0][1]] * _player.attack)
			var change := _Change.instance()
			add_child(change)
			change.text = str(_player.skills[_spell_queue[0][0] * 3 +\
			_spell_queue[0][1]] * _player.attack)
			change.rect_global_position = $Battlers.get_child(_target).global_position - Vector2(0, 100)
			var spell := _Spell.instance()
			add_child(spell)
			spell.get_child(0).interpolate_property(
				spell,
				"global_position",
				_player.global_position - Vector2(0, 32),
				$Battlers.get_child(_target).global_position - Vector2(0, 32),
				1.0
			)
			spell.get_child(0).start()
			yield($Battlers.get_child(_target), "anim_finished")
			spell.queue_free()
			_spell_queue.remove(0)
			_change_state(ENEMY)
		ENEMY:
			for child in $Battlers.get_children():
				if child is AnimatedSprite and not child.name == "Witch":
					var dmg: int = child.skills[randi() % child.skills.size()] * child.attack
					_player.change_health(dmg)
					var change := _Change.instance()
					change.text = str(dmg)
					add_child(change)
					change.rect_global_position = _player.global_position - Vector2(0, 100)
					yield(_player, "anim_finished")
			if _spell_queue.size() == 0:
				_change_state(WAIT)
			elif not _state == OVER:
				_change_state(PLAYER)
		OVER:
			if _won:
				$Over/VBoxContainer/Label.text = "You won!"
			else:
				$Over/VBoxContainer/Label.text = "You lost!"
			$Over.popup_centered()


func _on_back_pressed() -> void:
	emit_signal("scene_change_requested", "res://scenes/overworld/overworld.tscn")
