@tool
extends Node2D

## 坦克生产工厂类
class_name TankFactory

## 红坦克收到攻击时的反馈事件
signal red_tank_attacked()

## 敌人增加增援
signal tank_reinforcements()

## 是否开启debug模式
@export
var _debug_mode: bool = false

## 红坦克的索引值集合
@export
var red_tank_indexs: Array[int] = []

## 坦克出生点位集合
@export
var born_positions: Array[Vector2]

## 玩家出生的点位
var player_born_position = Vector2(\
	GameGlobals.GAME_MAP_SIZE.x / 2.0 - 48.0, \
	GameGlobals.GAME_MAP_SIZE.y - 16.0)

## 出生同步锁对象
var _born_mutex: Mutex = Mutex.new()

## 等待生产的点位信息
var _wait_born_positions: Dictionary[Variant, Vector2] = {}

## 生产了的坦克的总数
var _genereate_enemy_count: int = 0

## 出生的敌方坦克总数
var _born_total_count: int = GameGlobals.DEFAULT_ENEMY_TOTAL_COUNT

## 在地图上的敌方坦克总数量
var _total_count_in_map: int = GameGlobals.DEFAULT_ENEMY_COUNT_IN_MAP

## 生成一个敌方坦克后，会发送该事件
signal on_born_one_enemy_tank()

func _ready() -> void:
	_wait_born_positions = {
		0: born_positions[0],
		1: born_positions[1],
		2: born_positions[2],
	}
	await get_tree().create_timer(2.0).timeout
	_layout_and_bind_born_areas() # 布局出生范围

func _process(_delta: float) -> void:
	pass

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, GameGlobals.GAME_MAP_SIZE), Color.BLACK, false)

# 生成玩家坦克
func generate_player_tank(explode_finished: Callable) -> void:
	var tank = Tank.create(\
		GameEnums.TankType.player, \
		player_born_position, Vector2.UP)
	tank.allow_control = true
	tank.set_render_index(100)
	tank.set_capabilities([ \
		# CapabilityProperty.Ferry.new(), \
		CapabilityProperty.ProtectClothes.new(10.0)])
	tank.explode_finished.connect(explode_finished)
	add_child(tank) # 添加到坦克工厂节点

## 生成敌方的坦克
func _generate_enemy_tank(born_position: Vector2) -> void:
	_born_total_count -= 1 # 每生产一个，总数量减少1
	_genereate_enemy_count += 1 # 每生产一个，数量增加1
	var is_red_tank = \
		(_genereate_enemy_count - 1) in red_tank_indexs
	var tank = Tank.create(\
		GameEnums.TankType.enemy, born_position, Vector2.DOWN)
	tank.set_render_index(1000)
	if is_red_tank: # 如果是红坦克，生成随机闪烁次数
		var times = randi_range(1, 3)
		tank.set_red_blink_times(times)
		tank.red_tank_attacked \
			.connect(func(): red_tank_attacked.emit())
	tank.tank_reinforcements.connect(_on_tank_reinforcements)
	add_child(tank) # 添加生成的坦克到子节点
	on_born_one_enemy_tank.emit() # 发送事件，标记生产了一个敌人坦克

## 增加坦克救援
func _on_tank_reinforcements(type: GameEnums.TankType) -> void:
	if type != GameEnums.TankType.player:
		_born_total_count += 1
	tank_reinforcements.emit(type) #提交事件

## 执行生成坦克的定时器回调
func _on_born_timer_timeout() -> void:
	_born_mutex.lock()
	var nodes = get_tree() \
		.get_nodes_in_group(&'enemy_tank') \
		.filter(func(e): return is_instance_valid(e as Tank))
	var now_count = nodes.size()
	if now_count >= _total_count_in_map:
		_born_mutex.unlock()
		return
	var should_born_count = \
		(_total_count_in_map - now_count if \
			_born_total_count >= _total_count_in_map \
				else _born_total_count % _total_count_in_map)
	if should_born_count <= 0:
		_born_mutex.unlock()
		return # 不符合生产条件，直接返回
	for i in range(0, should_born_count):
		var keys = _wait_born_positions.keys()
		if keys.is_empty(): break
		var rand_key = keys.pick_random()
		if rand_key == null: continue
		var born_position = _wait_born_positions[rand_key]
		if born_position == null or \
			born_position == Vector2.ZERO: continue
		_wait_born_positions.erase(rand_key)
		_generate_enemy_tank(born_position) # 满足条件时，生成需要的坦克对象
	_born_mutex.unlock()

## 布局出生范围和事件绑定
func _layout_and_bind_born_areas() -> void:
	if Engine.is_editor_hint(): return
	var nodes = get_children() \
		.filter(func(e): return e is EnemyBornArea)
	for index in range(0, nodes.size()): # 循环生成敌人的出生点位
		var node = nodes[index] as EnemyBornArea
		node._debug_mode = _debug_mode
		node.set_tag_variant(index)
		node.set_tag_position(born_positions[index])
		node.on_tank_stay_here.connect(_on_tank_stay_born_area)
		node.on_none_tank_here.connect(_on_none_tank_stay_born_area)

## 有坦克待在某个出生点位
func _on_tank_stay_born_area(tag: Variant, _location: Vector2) -> void:
	if _wait_born_positions.has(tag): # 如果记录过，则删除这条记录
		_wait_born_positions.erase(tag)

## 没有坦克待在某个出生点位
func _on_none_tank_stay_born_area(tag: Variant, location: Vector2) -> void:
	_wait_born_positions[tag] = location
