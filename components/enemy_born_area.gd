extends Area2D

## 敌方出生区域
class_name EnemyBornArea

## 是否是debug模式
@export
var _debug_mode: bool

## 位置标志信息
@export
var _tag: Variant

## 位置信息的坐标数据
@export
var _tag_position: Vector2

## 处于出生区域的实体对象合集
var _collision_tanks: Array[Tank] = []

## 有坦克待在出生区域的事件信号
signal on_tank_stay_here(tag: Variant, location: Vector2)

## 没有坦克待在出生区域的事件信号
signal on_none_tank_here(tag: Variant, location: Vector2)

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _draw() -> void:
	if not _debug_mode: return
	draw_rect(Rect2(Vector2.ZERO, Vector2(32, 32)), Color.ANTIQUE_WHITE)
	
func _on_body_entered(body: Node2D) -> void:
	if body is Tank: 
		_collision_tanks.append(body)
	_clear_invalid_objects() #清理不可用的对象
	if not _collision_tanks.is_empty():
		on_tank_stay_here.emit(_tag, _tag_position)

func _on_body_exited(body: Node2D) -> void:
	if body is Tank and \
		_collision_tanks.any(func(e): return e == body):
		_collision_tanks.erase(body)
	_clear_invalid_objects() #清理不可用的对象
	if _collision_tanks.is_empty():
		on_none_tank_here.emit(_tag, _tag_position)

## 清理不可用的对象
func _clear_invalid_objects() -> void:
	var nodes = _collision_tanks.filter( \
		func(e): return not is_instance_valid(e))
	for node in nodes: _collision_tanks.erase(node)

## 判断是否存在空地
func has_empty_place() -> bool:
	return _collision_tanks.is_empty()
	
func set_tag(tag: Variant) -> void:
	_tag = tag

func get_tag() -> Variant: return _tag

## 设置判断位置
func set_tag_position(location: Vector2) -> void:
	position = location
	_tag_position = location

## 获取判断位置
func get_tag_position() -> Vector2: return _tag_position

## 创建实例
static func create(born_position: Vector2) -> EnemyBornArea:
	var instance = (load('res://components/enemy_born_area.tscn') \
		as PackedScene).instantiate() as EnemyBornArea
	instance.set_tag_position(born_position)
	return instance
