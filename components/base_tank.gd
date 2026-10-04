@tool
extends CharacterBody2D

class_name BaseTank

# 移动速度
@export
var speed: float = 100.0

# 坦克类型
@export
var _tank_type: GameEnums.TankType

# 朝向变量
@export
var _facing_dir: Vector2 = Vector2.UP

@export
var _tank_sprite: Sprite2D

@export
var _tank_pivot: Node2D

@export
var _collision_shape: CollisionShape2D

func _ready() -> void:
	set_tank_type(_tank_type)
	if _tank_type == GameEnums.TankType.player:
		set_collision_layer_value(CollisionLayers.layer_player_tank, true)
	else: set_collision_layer_value(CollisionLayers.layer_enemy_tank, true)

func _process(delta: float) -> void:
	var target_dir = Vector2.ZERO
	if Input.is_action_pressed('ui_left'):
		target_dir = Vector2.LEFT
	elif Input.is_action_pressed('ui_right'):
		target_dir = Vector2.RIGHT
	elif Input.is_action_pressed('ui_up'):
		target_dir = Vector2.UP
	elif Input.is_action_pressed('ui_down'):
		target_dir = Vector2.DOWN
	set_facing_dir(target_dir)
	var collide = move_and_collide(target_dir * speed * delta) # 执行移动逻辑
	if not collide or not collide.get_collider(): return

# 设置渲染层级
func set_render_index(index: int) -> void:
	_tank_sprite.z_index = index

# 设置坦克类型
func set_tank_type(type: GameEnums.TankType) -> void:
	_tank_type = type
	set_facing_dir(_facing_dir)
	var shape = RectangleShape2D.new()
	shape.size = _tank_sprite.texture.get_size()
	_collision_shape.shape = shape
	var offset = shape.size / 2.0
	_tank_pivot.position = - offset
	_collision_shape.position = - offset

# 获取坦克类型
func get_tank_type() -> GameEnums.TankType: return _tank_type

# 转换不标准的方向到标准方向
func _convert_dir_to_direction(dir: Vector2) -> String:
	if dir == Vector2.ZERO: return ""
	if dir == Vector2.LEFT: return "left"
	elif dir == Vector2.RIGHT: return "right"
	elif dir == Vector2.UP: return "up"
	elif dir == Vector2.DOWN: return "down"
	else: return ""

# 设置朝向
func set_facing_dir(dir: Vector2) -> void:
	if dir == Vector2.ZERO: return
	_facing_dir = dir # 更新当前的朝向数据
	var dir_name = _convert_dir_to_direction(dir)
	if dir_name == "": return
	_tank_sprite.texture = \
		load('res://assets/textures/tank_player/tank_player_{0}.tres'.format([dir_name])) as AtlasTexture
		

# 获取朝向数据
func get_facing_dir() -> Vector2: return _facing_dir

# 显示被保护的状态
func show_protected_effect() -> void:
	pass

# 显示闪烁状态
func show_flink_effect() -> void:
	pass

# 显示红色闪烁状态
func show_red_flink_effect() -> void:
	pass

# 显示爆炸销毁状态
func show_explode_destroy_effect() -> void:
	pass
