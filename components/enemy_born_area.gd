extends Area2D

var _tag_position: Vector2

var _collision_tanks: Array[Tank] = []

signal on_none_tank_here(location: Vector2)

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
	
func _on_body_entered(body: Node2D) -> void:
	if body is Tank: 
		_collision_tanks.append(body)
	_clear_invalid_objects()

func _on_body_exited(body: Node2D) -> void:
	if body is Tank and \
		_collision_tanks.any(func(e): e == body):
		_collision_tanks.erase(body)
	if _collision_tanks.is_empty():
		on_none_tank_here.emit()
	_clear_invalid_objects()

func _clear_invalid_objects() -> void:
	var nodes = _collision_tanks.filter( \
		func(e): not is_instance_valid(e))
	for node in nodes: _collision_tanks.erase(node)

func has_empty_place() -> bool:
	return _collision_tanks.is_empty()

func set_tag_position(location: Vector2) -> void:
	_tag_position = location

func get_tag_position() -> Vector2: return _tag_position
