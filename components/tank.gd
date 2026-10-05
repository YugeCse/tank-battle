@tool
extends CharacterBody2D

class_name Tank

# 是否允许被控制
@export
var allow_control: bool

# 移动速度
@export
var speed: float = 100.0

# 坦克类型
@export
var _tank_type: GameEnums.TankType

# 朝向变量
@export
var _facing_dir: Vector2 = Vector2.UP

# 能力容器
var _capabilities: Array[CapabilityProperty] = []

@export
var _tank_sprite: Sprite2D

@export
var _tank_pivot: Node2D

@export
var _collision_shape: CollisionShape2D

# 动画精灵,用于展示一些效果
@export
var _animated_sprite: AnimatedSprite2D

# 保护衣特效的定时器
var _protect_effect_timer: Timer

# 闪烁动画
var _flicker_tween: Tween

# 红色闪烁动画
var _red_flicker_tween: Tween

@export
var _tank_atlas_textures: Dictionary[String, AtlasTexture]

func _ready() -> void:
	set_tank_type(_tank_type)
	if has_protect_clothes():
		show_protected_effect()
	if _tank_type == GameEnums.TankType.player:
		set_collision_layer_value(CollisionLayers.layer_player_tank, true)
	else: set_collision_layer_value(CollisionLayers.layer_enemy_tank, true)
	# 2s后执行闪烁动画
	get_tree().create_timer(2.0).timeout.connect(func(): show_red_blink_effect())

func _process(delta: float) -> void:
	if allow_control:
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
	else: 
		pass #自主随机移动

func _draw() -> void:
	if not has_ferry_capability(): return
	var box = StyleBoxFlat.new()
	box.set_border_width_all(2)
	box.set_corner_radius_all(8)
	box.bg_color = Color.TRANSPARENT
	box.border_color = Color.WHITE_SMOKE
	var rect = _tank_sprite.get_rect()
	var rect_s = rect.size / 2.0
	var new_rect = Rect2( \
		rect.position.x - rect_s.x, \
		rect.position.y - rect_s.y, \
		rect.size.x, rect.size.y)
	draw_style_box(box, new_rect.grow(2.0))

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
	_tank_sprite.texture = _tank_atlas_textures[dir_name]

# 获取朝向数据
func get_facing_dir() -> Vector2: return _facing_dir

# 设置能力组合
func set_capabilities(capabilities: Array[CapabilityProperty]) -> void:
	_capabilities = capabilities

# 获取现有的能力组合
func get_capabilities() -> Array[CapabilityProperty]: return _capabilities

# 是否有轮渡能力
func has_ferry_capability() -> bool:
	return _capabilities.any(func(e): return e is CapabilityProperty.Ferry)

# 是否有保护衣的能力
func has_protect_clothes() -> bool: 
	return _capabilities.any(func(e): return e is CapabilityProperty.ProtectClothes)

# 更新精灵
func update_sprite( \
	new_textures: Dictionary[String, AtlasTexture]) -> void:
	_tank_atlas_textures = new_textures
	var dir_name = _convert_dir_to_direction(_facing_dir)
	if dir_name == "": return
	_tank_sprite.texture = _tank_atlas_textures[dir_name]

# 显示被保护的状态
func show_protected_effect() -> void:
	_release_protect_effect_timer()
	
	_animated_sprite.visible = true
	_animated_sprite.play('protect')
	
	var holdon_sec = (
		_capabilities.filter( \
		func(e): return e is CapabilityProperty.ProtectClothes)[0] \
		as CapabilityProperty.ProtectClothes).hold_on_time_sec
	_protect_effect_timer = Timer.new()
	_protect_effect_timer.one_shot = true
	_protect_effect_timer.timeout \
		.connect(func(): stop_protected_effect())
	add_child(_protect_effect_timer)
	_protect_effect_timer.start(holdon_sec)

# 停止保护衣动画状态
func stop_protected_effect() -> void:
	_release_protect_effect_timer()
	_animated_sprite.stop()
	_animated_sprite.visible = false
	# 删除对应的能力
	var objs = _capabilities.filter( \
		func(e): return e is CapabilityProperty.ProtectClothes)
	for obj in objs: _capabilities.erase(obj)

# 释放保护衣特效定时器
func _release_protect_effect_timer() -> void:
	if not _protect_effect_timer: return
	if not _protect_effect_timer.is_stopped():
		_protect_effect_timer.stop()
	_protect_effect_timer.queue_free()
	_protect_effect_timer = null

# 显示闪烁状态
func show_blink_effect() -> void:
	_dispose_blink_effect() #取消闪烁动画
	_flicker_tween = get_tree().create_tween().set_loops(0)
	_flicker_tween.tween_property(_tank_sprite, "modulate:a", 0.2, 0.5)
	_flicker_tween.tween_property(_tank_sprite, "modulate:a", 1.0, 0.5)

# 取消闪烁动画
func _dispose_blink_effect() -> void:
	if not _flicker_tween: return
	_flicker_tween.kill()
	_flicker_tween = null
	_tank_sprite.set_deferred('modulate:a', 1.0)

# 显示红色闪烁状态
func show_red_blink_effect() -> void:
	_dispose_red_blink_effect()
	_red_flicker_tween = get_tree().create_tween().set_loops(0)
	_red_flicker_tween.tween_property(_tank_sprite, "modulate", Color.WHITE, 0.5)
	_red_flicker_tween.tween_property(_tank_sprite, "modulate", Color.DARK_RED, 0.5)

# 取消红色闪烁动画
func _dispose_red_blink_effect() -> void:
	if not _red_flicker_tween: return
	_red_flicker_tween.kill()
	_red_flicker_tween = null
	_tank_sprite.set_deferred('modulate:a', 1.0)

# 显示爆炸销毁状态
func show_explode_destroy_effect() -> void:
	pass

# 创建一个实例
static func create( \
	type: GameEnums.TankType, \
	location: Vector2 \
) -> Tank:
	var instance = \
		(load("res://components/tank.tscn") \
		as PackedScene).instantiate() as Tank
	instance.position = location
	instance.update_sprite(get_tank_atlas_textures(type))
	instance.set_tank_type(type) #设置坦克类型
	return instance

# 获取玩家的 texture 资源
static func get_tank_atlas_textures(type: GameEnums.TankType) -> Dictionary[String, AtlasTexture]:
	var dic: Dictionary[String, AtlasTexture] = {}
	var dirs = ['left', 'right', 'up', 'down']
	for dir in dirs:
		if type == GameEnums.TankType.player:
			dic[dir] = load( \
				"res://assets/textures/tank_player/tank_player_{0}.tres" \
				.format([dir])) as AtlasTexture
		elif type == GameEnums.TankType.enemy:
			dic[dir] = load( \
				"res://assets/textures/tank_enemies/tank_enemy0_{0}.tres" \
				.format([dir])) as AtlasTexture
		elif type == GameEnums.TankType.enemy1:
			dic[dir] = load( \
				"res://assets/textures/tank_enemies/tank_enemy1_{0}.tres" \
				.format([dir])) as AtlasTexture
		elif type == GameEnums.TankType.enemy2:
			dic[dir] = load( \
				"res://assets/textures/tank_enemies/tank_enemy2_{0}.tres" \
				.format([dir])) as AtlasTexture
		elif type == GameEnums.TankType.enemy3:
			dic[dir] = load( \
				"res://assets/textures/tank_enemies/tank_enemy3_{0}.tres" \
				.format([dir])) as AtlasTexture
		elif type == GameEnums.TankType.enemy4:
			dic[dir] = load( \
				"res://assets/textures/tank_enemies/tank_enemy4_{0}.tres" \
				.format([dir])) as AtlasTexture
	return dic
