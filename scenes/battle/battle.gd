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
const _Spell := preload("res://scenes/battle/spells/spell.tscn")

var _state: int
var _selected_blocks := []
var _drag_cancelled := false
var _spell_queue := []
var _enemies := []
var _target := 0
var _won := false
var _boss: bool

onready var _grid := $Blocks/Marg/Grid
onready var _player := $Battlers/Witch


func _ready() -> void:
	_grid.columns = _NUM_COLS
	for y in _NUM_ROWS:
		var row = []
		for x in _NUM_COLS:
			var t := _Block.instance()
			_grid.add_child(t)
			row.append(false)
	
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
		

func set_battlers(enemies: PoolStringArray, boss := false) -> void:
	_boss = boss
	var bg := ButtonGroup.new()
	for i in enemies.size():
		var e: AnimatedSprite = load(enemies[i]).instance()
		_enemies.append(e)
		$Battlers.get_child(i).add_child(e)
		e.connect("target_selected", self, "_on_target_selected")
		e.get_node("Target").group = bg
	$Battlers.get_child(_target).get_child(0).set_target()
	if boss:
		$Background.texture = load("res://scenes/battle/bg.png")
		$TextureRect.show()
		yield(get_tree().create_timer(6), "timeout")
		$TextureRect.hide()
		

func _on_target_selected(target: AnimatedSprite) -> void:
	_target = target.get_parent().get_index()
	
	
func _on_battler_died(battler: AnimatedSprite) -> void:
	if battler in _enemies:
		_enemies[_enemies.find(battler)] = null
		var not_all_null = false
		for i in _enemies:
			if i:
				not_all_null = true
				break
		if not not_all_null:
			_won = true
			_change_state(OVER)
		else:
			_target = clamp(_target, 0, _enemies.size() - 1)
			$Battlers.get_child(_target).get_child(0).set_target()
	else:
		_change_state(OVER)
	battler.queue_free()
	

func _get_block_coords(block: TextureRect) -> Vector2:
	return Vector2(block.get_index() % _NUM_COLS, block.get_index() / _NUM_COLS)


func _check_for_square() -> bool:
	if not _selected_blocks.size() == 4:
		return false
	var first_square: TextureRect
	var pos_0 := _get_block_coords(_selected_blocks[0])
	for i in range(1, 4):
		if (_get_block_coords(_selected_blocks[i]) - pos_0).abs() == Vector2(1, 1):
			first_square = _selected_blocks[i]
			break
	if not first_square:
		return false
	var second_square: TextureRect
	var pos_1 = _get_block_coords(first_square)
	for i in range(1, 4):
		var pos := _get_block_coords(_selected_blocks[i])
		if pos.x == pos_0.x and pos.y == pos_1.y:
			second_square = _selected_blocks[i]
			break
	if not second_square:
		return false
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
			var spell: Array = _spell_queue[0]
			_spell_queue.remove(0)
			var power: int = _player.attack * _player.skills[spell[0] * 3 + spell[1]]
			var target: AnimatedSprite
			if spell[0] == 2 and spell[1] == 2:
				target = _player
			else:
				target = $Battlers.get_child(_target).get_child(0)
				var spell_sprite = _Spell.instance()
				add_child(spell_sprite)
				spell_sprite.cast(spell[0], _player.global_position + Vector2(0, -32), target.global_position + Vector2(0, -32), 1.0)
				yield(spell_sprite, "tween_all_completed")
			target.change_health(power)
			yield(target, "anim_finished")
			if target.health == 0:
				_on_battler_died(target)
			if not _state == OVER:
				_change_state(ENEMY)
		ENEMY:
			for enemy in _enemies:
				var power: int = enemy.attack * enemy.skills[randi() % enemy.skills.size()]
				_player.change_health(power)
				yield(_player, "anim_finished")
			if _player.health == 0:
				_on_battler_died(_player)
			elif _spell_queue.size() == 0:
				_change_state(WAIT)
			else:
				_change_state(PLAYER)
		OVER:
			if _won:
				$Over/VBoxContainer/Label.text = "You won!"
				$Win.play()
				$Over.popup_centered()
			else:
				$Over/VBoxContainer/Label.text = "You lost!"
				$Lose.play()
				$GameOver.show()
				$Over.rect_position = Vector2(287, 47)
				$Over.popup()
			get_parent().won = _won


func _on_back_pressed() -> void:
	if _boss:
		if _won:
			emit_signal("scene_change_requested", "res://scenes/end/end.tscn")
		else:
			emit_signal("scene_change_requested", "res://scenes/battle/battle.tscn", PoolStringArray(["res://scenes/battle/battlers/boss/boss.tscn"]))
	else:
		emit_signal("scene_change_requested", "res://scenes/overworld/overworld.tscn")
