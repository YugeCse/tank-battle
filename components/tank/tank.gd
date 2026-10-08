@tool
extends CharacterBody2D

## 坦克类
class_name Tank

## 坦克爆炸完成事件
signal explode_finished()

## 红坦克收到攻击时的反馈事件
signal red_tank_attacked()

## 敌方坦克增援
signal tank_reinforcements(type: GameEnums.TankType)

## 是否允许被控制
@export
var allow_control: bool

## 血量，默认：1
var blood: int = 1

## 移动速度
@export
var speed: float = 100.0

## 坦克类型
@export
var _tank_type: GameEnums.TankType

## 朝向变量
@export
var _facing_dir: Vector2 = Vector2.UP

## 能力容器
var _capabilities: Array[CapabilityProperty] = []

## 玩家射击间隔时间
var _player_shoot_time_span: float = 0.3

## 玩家射击间隔时间统计
var _player_shoot_time_span_statistics: float = 0.0

## 坦克精灵
@export
var _tank_sprite: Sprite2D

## 坦克精灵碰撞形状
@export
var _collision_shape: CollisionShape2D

## 动画精灵,用于展示一些效果
@export
var _animated_sprite: AnimatedSprite2D

## 红色闪烁次数
var _red_blink_times: int = 0

## 闪烁动画对象
var _blink_tween: Tween

## 红色闪烁动画对象
var _red_blink_tween: Tween

## 保护衣特效的定时器
var _protect_effect_timer: Timer

## 自动移动的定时器
var _auto_move_timer: Timer

## 自动开火的定时器
var _auto_fire_timer: Timer

## 自动移动方向数据
var _auto_move_direction: Vector2 = Vector2.ZERO

## 生命状态
var _life_state: GameEnums.LifeState = GameEnums.LifeState.born

## 坦克资源数据合集
@export
var _tank_atlas_textures: Dictionary[String, AtlasTexture]

## 获取当前是否是出生状态
var is_born_state: bool:
	get: return _life_state == GameEnums.LifeState.born

## 获取生命状态
func get_life_state() -> GameEnums.LifeState: return _life_state

func _ready() -> void:
	set_collision_available(false) # 默认设置碰撞不可用
	set_tank_type(_tank_type) # 默认设置坦克类型
	set_facing_dir(_facing_dir) # 设置朝向数据
	show_born_effect() # 显示初始特效
	
func _process(delta: float) -> void:
	if Engine.is_editor_hint() or \
		_life_state != GameEnums.LifeState.alive: return
	var target_dir = Vector2.ZERO
	if allow_control:
		if Input.is_action_pressed('ui_left'):
			target_dir = Vector2.LEFT
		elif Input.is_action_pressed('ui_right'):
			target_dir = Vector2.RIGHT
		elif Input.is_action_pressed('ui_up'):
			target_dir = Vector2.UP
		elif Input.is_action_pressed('ui_down'):
			target_dir = Vector2.DOWN
		if Input.is_action_just_pressed('shoot'):
			_player_shoot_time_span = GameGlobals \
				.get_player_tank_shoot_span_time(self)
			if _player_shoot_time_span_statistics == 0.0 or \
				_player_shoot_time_span_statistics >= _player_shoot_time_span:
				if _player_shoot_time_span_statistics >= _player_shoot_time_span:
					_player_shoot_time_span_statistics = 0.0
				shoot() # 执行发射子弹
		_player_shoot_time_span_statistics += delta
	else: target_dir = _auto_move_direction
	if target_dir != Vector2.ZERO:
		set_facing_dir(target_dir)
	var collide = move_and_collide(target_dir * speed * delta) # 执行移动逻辑
	if not collide or not collide.get_collider(): return

func _draw() -> void:
	if not has_ferry_capability(): return
	var box = StyleBoxFlat.new()
	box.set_border_width_all(2)
	box.set_corner_radius_all(8)
	box.bg_color = Color.TRANSPARENT
	box.border_color = Color.WHITE_SMOKE
	var rect = _tank_sprite.get_rect()
	var rect_s = rect.size / 2.0
	var new_rect = Rect2(\
		rect.position.x - rect_s.x, \
		rect.position.y - rect_s.y, \
		rect.size.x, rect.size.y)
	draw_style_box(box, new_rect.grow(2.0))

## 设置渲染层级
func set_render_index(index: int) -> void:
	_tank_sprite.z_index = index

## 设置坦克类型
func set_tank_type(type: GameEnums.TankType) -> void:
	_tank_type = type
	set_facing_dir(_facing_dir)
	var shape = RectangleShape2D.new()
	shape.size = _tank_sprite.texture.get_size()
	_collision_shape.shape = shape
	# 设置碰撞相关的属性
	if _tank_type != GameEnums.TankType.player:
		add_to_group(&'enemy_tank', false)
		set_collision_layer_value(CollisionLayers.layer_enemy_tank, true)
		#set_collision_mask_value(CollisionLayers.layer_enemy_tank, false)
		set_collision_mask_value(CollisionLayers.layer_enemy_bullet, false)
	else:
		add_to_group(&'player_tank', false)
		set_collision_layer_value(CollisionLayers.layer_player_tank, true)
		#set_collision_mask_value(CollisionLayers.layer_player_tank, false)
		set_collision_mask_value(CollisionLayers.layer_player_bullet, false)

## 获取坦克类型
func get_tank_type() -> GameEnums.TankType: return _tank_type

## 转换不标准的方向到标准方向
func _convert_dir_to_direction(dir: Vector2) -> String:
	if dir == Vector2.ZERO: return ""
	if dir == Vector2.LEFT: return "left"
	elif dir == Vector2.RIGHT: return "right"
	elif dir == Vector2.UP: return "up"
	elif dir == Vector2.DOWN: return "down"
	else: return ""

## 设置朝向
func set_facing_dir(dir: Vector2) -> void:
	if dir == Vector2.ZERO: return
	_facing_dir = dir # 更新当前的朝向数据
	var dir_name = _convert_dir_to_direction(dir)
	if dir_name == "": return
	_tank_sprite.texture = _tank_atlas_textures[dir_name]

## 获取朝向数据
func get_facing_dir() -> Vector2: return _facing_dir

## 设置能力组合
func set_capabilities(capabilities: Array[CapabilityProperty]) -> void:
	_capabilities = capabilities

## 获取现有的能力组合
func get_capabilities() -> Array[CapabilityProperty]: return _capabilities

## 是否有轮渡能力
func has_ferry_capability() -> bool:
	return _capabilities.any(func(e): \
		return e is CapabilityProperty.Ferry)

## 是否有保护衣的能力
func has_protect_clothes() -> bool:
	return _capabilities.any(func(e): return e is CapabilityProperty.ProtectClothes)

## 是否有增强火力的能力
func has_strong_fire_capability() -> bool:
	return _capabilities.any(func(e): \
		return e is CapabilityProperty.StrongFire)

## 获取加强火力的能力
func get_strong_fire_capability() -> DataResult:
	var capabilities = _capabilities.filter(func(e): \
		return e is CapabilityProperty.StrongFire)
	if capabilities.is_empty():
		return DataResult.fail('没有加强火力的能力')
	return DataResult.ok(capabilities[0])

## 更新精灵
func update_sprite(\
	new_textures: Dictionary[String, AtlasTexture]) -> void:
	_tank_atlas_textures = new_textures
	var dir_name = _convert_dir_to_direction(_facing_dir)
	if dir_name == "": return
	_tank_sprite.texture = _tank_atlas_textures[dir_name]

## 设置碰撞是否可用
func set_collision_available(value: bool) -> void:
	_collision_shape.set_deferred('disabled', !value)

## 发射子弹
func shoot() -> void:
	var location = position
	var tank_size = _tank_sprite.get_rect().size
	if _facing_dir == Vector2.LEFT or \
		_facing_dir == Vector2.RIGHT:
		location.x = location.x + sign(_facing_dir.x) * tank_size.x / 4.0
	else:
		location.y = location.y + sign(_facing_dir.y) * tank_size.y / 4.0
	var bullet = Bullet.create(\
		location, _facing_dir, _tank_type)
	GameGlobals.add_child_to_war_map.emit(bullet)

## 拾取道具
func fetch_prop(type: GameEnums.TankPropType) -> void:
	match type:
		GameEnums.TankPropType.timer: #定时器
			pass
		GameEnums.TankPropType.star: #五角星
			pass
		GameEnums.TankPropType.bomb: #炸弹处理
			if _tank_type == GameEnums.TankType.player:
				var tanks = get_tree().get_nodes_in_group(&'enemy_tank')
				for tank in tanks: (tank as Tank).show_explode_destroy_effect()
			else: 
				var tanks = get_tree().get_nodes_in_group(&'player_tank')
				for tank in tanks: (tank as Tank).show_explode_destroy_effect()
		GameEnums.TankPropType.hat: # 获得保护帽
			if has_protect_clothes():
				var capas = _capabilities.filter(func(e): \
					return e is CapabilityProperty.ProtectClothes)
				for capa in capas: _capabilities.erase(capa)
			_capabilities.append(CapabilityProperty.ProtectClothes.new())
			show_protected_effect() # 添加保护特效
		GameEnums.TankPropType.master_defense: #总部防御
			pass
		GameEnums.TankPropType.reinforcements: #增加增援
			tank_reinforcements.emit(_tank_type) #添加一个敌人的坦克
	print('拾取道具: {0}'.format([GameEnums.get_tank_prop_type_description(type)]))

## 显示出生状态
func show_born_effect() -> void:
	_tank_sprite.visible = false
	_animated_sprite.visible = true
	_animated_sprite.animation_finished \
		.connect(func(): _on_born_effect_finished())
	_animated_sprite.play('born') # 播放出生特效

## 出生特效完成时的事件
func _on_born_effect_finished() -> void:
	_life_state = GameEnums.LifeState.alive
	_tank_sprite.visible = true
	_animated_sprite.visible = false
	set_collision_available(true) # 设置此时碰撞状态可用
	if _tank_type == GameEnums.TankType.player:
		#如果有保护衣，则显示被保护状态
		if has_protect_clothes():
			show_protected_effect()
	else:
		start_auto_move_timer() # 启动自动移动的定时器
		start_auto_fire_timer() # 启动自动开火的定时器
	if _red_blink_times > 0: show_red_blink_effect()

## 显示被保护的状态
func show_protected_effect() -> void:
	_release_protect_effect_timer()
	_animated_sprite.visible = true
	_animated_sprite.play('protect')
	var holdon_sec = (
		_capabilities.filter(\
		func(e): return e is CapabilityProperty.ProtectClothes)[0] \
		as CapabilityProperty.ProtectClothes).hold_on_time_sec
	_protect_effect_timer = Timer.new()
	_protect_effect_timer.one_shot = true
	_protect_effect_timer.timeout \
		.connect(func(): stop_protected_effect())
	add_child(_protect_effect_timer)
	_protect_effect_timer.start(holdon_sec)

## 停止保护衣动画状态
func stop_protected_effect() -> void:
	_release_protect_effect_timer()
	_animated_sprite.stop()
	_animated_sprite.visible = false
	# 删除对应的能力
	var objs = _capabilities.filter(\
		func(e): return e is CapabilityProperty.ProtectClothes)
	for obj in objs: _capabilities.erase(obj)

## 释放保护衣特效定时器
func _release_protect_effect_timer() -> void:
	if not _protect_effect_timer: return
	if not _protect_effect_timer.is_stopped():
		_protect_effect_timer.stop()
	_protect_effect_timer.queue_free()
	_protect_effect_timer = null

## 显示闪烁状态
func show_blink_effect() -> void:
	dispose_blink_effect() # 取消闪烁动画
	_blink_tween = get_tree().create_tween().set_loops(0)
	_blink_tween.tween_property(_tank_sprite, "modulate:a", 0.2, 0.5)
	_blink_tween.tween_property(_tank_sprite, "modulate:a", 1.0, 0.5)

# 取消闪烁动画
func dispose_blink_effect() -> void:
	if not _blink_tween: return
	_blink_tween.kill()
	_blink_tween = null
	_tank_sprite.set_deferred('modulate:a', 1.0)

## 设置红色闪烁次数
func set_red_blink_times(times: int) -> void:
	_red_blink_times = times

## 获取红色闪烁的次数
func get_red_blink_times() -> int: return _red_blink_times

## 显示红色闪烁状态
func show_red_blink_effect() -> void:
	dispose_red_blink_effect()
	_red_blink_tween = get_tree().create_tween().set_loops(0)
	_red_blink_tween.tween_property(_tank_sprite, "modulate", Color.WHITE, 0.5)
	_red_blink_tween.tween_property(_tank_sprite, "modulate", Color.DARK_RED, 0.5)

## 取消红色闪烁动画
func dispose_red_blink_effect() -> void:
	if not _red_blink_tween: return
	_red_blink_tween.kill()
	_red_blink_tween = null
	_tank_sprite.set_deferred('modulate:a', 1.0)

## 受到攻击
func attacked(attached_point: int) -> void:
	if _red_blink_times > 0:
		_red_blink_times -= 1
		red_tank_attacked.emit()
		return
	if _red_blink_tween:
		dispose_red_blink_effect()
	if blood >= 1:
		blood -= attached_point # 减少血量
	if blood <= 0: show_explode_destroy_effect()

## 显示爆炸销毁状态
func show_explode_destroy_effect() -> void:
	set_deferred('visible', false)
	_life_state = GameEnums.LifeState.death
	_collision_shape.set_deferred('disabled', true)
	var explode_effect = ExplodeEffect \
		.create(position, true)
	explode_effect.z_index = z_index
	GameGlobals.add_child_to_war_map.emit(explode_effect)
	explode_effect.explode_finished.connect(_on_explode_finished)

## 爆炸完成，通知外部事件
func _on_explode_finished() -> void:
	explode_finished.emit()
	await get_tree().create_timer(0.5).timeout
	queue_free() # 从节点中删除

## 启动自动移动的定时器
func start_auto_move_timer(wait_time: Variant = null) -> void:
	var rand_sec = wait_time \
		if wait_time != null else randf_range(0.5, 2.3)
	_release_auto_move_timer()
	_auto_move_timer = Timer.new()
	_auto_move_timer.one_shot = true
	_auto_move_timer.wait_time = rand_sec
	_auto_move_timer.timeout.connect(_on_auto_move_timer_finished)
	_auto_move_timer.autostart = true
	add_child(_auto_move_timer)

## 释放自动移动的定时器
func _release_auto_move_timer() -> void:
	if not _auto_move_timer: return
	if not _auto_move_timer.is_stopped():
		_auto_move_timer.stop()
	_auto_move_timer.queue_free()
	_auto_move_timer = null

## 自动移动的定时器完成时的事件
func _on_auto_move_timer_finished() -> void:
	if _life_state != GameEnums.LifeState.alive: return
	var dirs = [Vector2.ZERO, Vector2.UP, \
		Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	dirs.erase(_facing_dir)
	_auto_move_direction = dirs.pick_random()
	start_auto_move_timer() # 启动自动移动的定时器

## 启动自动开火的定时器
func start_auto_fire_timer(wait_time: Variant = null) -> void:
	var rand_sec = wait_time \
		if wait_time != null else randf_range(0.5, 2.3)
	_release_auto_fire_timer()
	_auto_fire_timer = Timer.new()
	_auto_fire_timer.one_shot = true
	_auto_move_timer.wait_time = rand_sec
	_auto_fire_timer.timeout.connect(_on_auto_fire_timer_finished)
	_auto_fire_timer.autostart = true
	add_child(_auto_fire_timer)

## 释放自动开火的定时器
func _release_auto_fire_timer() -> void:
	if not _auto_fire_timer: return
	if not _auto_fire_timer.is_stopped():
		_auto_fire_timer.stop()
	_auto_fire_timer.queue_free()
	_auto_fire_timer = null

## 自动开火定时器完成任务
func _on_auto_fire_timer_finished() -> void:
	if _life_state != GameEnums.LifeState.alive: return
	shoot() # 发起开火
	start_auto_fire_timer() # 启动自动开火的定时器

## 创建一个实例
static func create(\
	type: GameEnums.TankType, \
	location: Vector2, \
	facing_dir: Vector2,
) -> Tank:
	var instance = \
		(load("res://components/tank/tank.tscn") \
		as PackedScene).instantiate() as Tank
	instance.position = location
	instance.update_sprite(get_tank_atlas_textures(type))
	instance.set_tank_type(type) # 设置坦克类型
	instance.set_facing_dir(facing_dir)
	return instance

## 获取玩家的 texture 资源
static func get_tank_atlas_textures(type: GameEnums.TankType) -> Dictionary[String, AtlasTexture]:
	var dic: Dictionary[String, AtlasTexture] = {}
	var dirs = ['left', 'right', 'up', 'down']
	for dir in dirs:
		if type == GameEnums.TankType.player:
			dic[dir] = load(\
				"res://assets/textures/tank_player/tank_player_{0}.tres" \
				.format([dir])) as AtlasTexture
		elif type == GameEnums.TankType.enemy:
			dic[dir] = load(\
				"res://assets/textures/tank_enemies/tank_enemy0_{0}.tres" \
				.format([dir])) as AtlasTexture
		elif type == GameEnums.TankType.enemy1:
			dic[dir] = load(\
				"res://assets/textures/tank_enemies/tank_enemy1_{0}.tres" \
				.format([dir])) as AtlasTexture
		elif type == GameEnums.TankType.enemy2:
			dic[dir] = load(\
				"res://assets/textures/tank_enemies/tank_enemy2_{0}.tres" \
				.format([dir])) as AtlasTexture
		elif type == GameEnums.TankType.enemy3:
			dic[dir] = load(\
				"res://assets/textures/tank_enemies/tank_enemy3_{0}.tres" \
				.format([dir])) as AtlasTexture
		elif type == GameEnums.TankType.enemy4:
			dic[dir] = load(\
				"res://assets/textures/tank_enemies/tank_enemy4_{0}.tres" \
				.format([dir])) as AtlasTexture
	return dic
