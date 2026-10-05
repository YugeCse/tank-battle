extends Area2D

## 子弹对象
class_name Bullet

## 子弹运行方向
var _run_dir: Vector2

## 子弹的拥有者
var _sender: GameEnums.TankType

## 运行速度
@export
var speed: float = 150

## 子弹精灵
@export
var _bullet_sprite: Sprite2D

## 碰撞矩形
@export
var _collision_shape: CollisionShape2D

## 子弹精灵对应的四个方向的资源集合
@export
var _bullet_sprite_tres: Dictionary[String, AtlasTexture]

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	position += _run_dir * speed * delta

func set_run_dir(dir: Vector2) -> void:
	if dir == Vector2.ZERO: return
	_run_dir = dir
	var dir_name = ''
	match _run_dir:
		Vector2.UP: dir_name = 'up'
		Vector2.DOWN: dir_name = 'down'
		Vector2.LEFT: dir_name = 'left'
		Vector2.RIGHT: dir_name = 'right'
	if dir_name == '': return
	_bullet_sprite.texture = _bullet_sprite_tres[dir_name]
	var shape = RectangleShape2D.new()
	shape.size = _bullet_sprite.texture.get_size()
	_collision_shape.shape = shape

func get_run_dir() -> Vector2: return _run_dir

func set_sender(sender: GameEnums.TankType) -> void: _sender = sender

func get_sender() -> GameEnums.TankType: return _sender

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body.collision_layer == CollisionLayers.layer_boundary:
			print('到达游戏边界了')
			queue_free()
	pass # Replace with function body.

## 创建实例
static func create( \
	location: Vector2, \
	move_dir: Vector2, \
	sender: GameEnums.TankType) -> Bullet:
	var instance = (load('res://components/bullet.tscn') \
		as PackedScene).instantiate() as Bullet
	instance.set_sender(sender)
	instance.position = location
	instance.set_run_dir(move_dir)
	return instance
