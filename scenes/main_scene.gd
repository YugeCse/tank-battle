@tool
extends Node2D

# 地图容器
@export
var _map_container: Node2D

# 游戏结束的标记精灵
@export
var _game_over_tag: Sprite2D

# 敌人标志资源
@export
var _enemy_tag_atlas: AtlasTexture

# 敌人表格数据
@export
var _enemy_grid_container: GridContainer

# 关卡组件
@export
var _stage_level: NumberText

# 玩家生命组件
@export
var _player_lifes: NumberText

@export
var _enemy_tank_factory: TankFactory

var _enemy_tank_factory_mutex: Mutex = Mutex.new()

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	GameGlobals.add_child_to_war_map \
		.connect(func(e): _on_add_child_to_war_map(e)) #添加新节点到地图中
	_enemy_tank_factory.on_born_one_enemy_tank \
		.connect(_remove_one_from_enemy_grids) #如果生产一个敌方坦克，移除一个标志

func _ready() -> void:
	_stage_level.set_number(\
		1 if Engine.is_editor_hint() else GameGlobals.get_stage_level())
	_player_lifes.set_number( \
		3 if Engine.is_editor_hint() else GameGlobals.get_player_life_count())
	_generate_enemy_grids() #生成敌方表格数据
	if not Engine.is_editor_hint():
		_game_over_tag.visible = false #设置默认不可见
	_game_over_tag.position.x = GameGlobals.GAME_MAP_CONTAINER_SIZE.x / 2.0
	_load_map_tiles(_stage_level.get_number()) #加载地图数据
	_generate_player_tank() #生成玩家坦克
	_play_start_game_audio() #播放开始游戏的音频

## 播放开始游戏的音频
func _play_start_game_audio():
	if Engine.is_editor_hint() or \
		not GameGlobals.get_music_available(): return
	var audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.stream = load('res://assets/sounds/start.mp3')
	audio_stream_player.autoplay = true
	add_child(audio_stream_player)

## 收到添加子节点到地图节点的信号事件
func _on_add_child_to_war_map(node: Node2D) -> void:
	_map_container.add_child(node)

func _draw() -> void:
	var visible_rect = get_viewport_rect()
	draw_rect(visible_rect, Color("#7e7e7e"))

## 加载地图数据
func _load_map_tiles(stage: int) -> void:
	var map_data_result = GameGlobals.get_map_data(stage)
	if map_data_result.success:
		var map_data = map_data_result.value
		_layout_map_tiles(map_data)
	else: print('地图数据加载失败!!!')

## 排版地图地砖精灵
func _layout_map_tiles(map_data: Array) -> void:
	for child in _map_container.get_children():
		if child is MapTile: child.queue_free()
	for row in map_data.size():
		for column in map_data[row].size():
			var dat = map_data[row][column] as int
			if dat not in GameEnums.all_map_tile_types:
				continue
			var type = GameEnums.all_map_tile_types \
				.filter(func(t): return t == dat)[0] \
					as GameEnums.MapTileType
			var location = Vector2( \
				column * GameGlobals.GAME_MAP_TILE_SIZE, \
				row * GameGlobals.GAME_MAP_TILE_SIZE)
			var map_tile = MapTile.create(location)
			map_tile.set_map_title_type(type)
			map_tile.set_render_index(0)
			_map_container.add_child(map_tile)

## 生成敌方表格数据
func _generate_enemy_grids() -> void:
	_clear_enemy_grids_in_container()
	var total = 20 if Engine.is_editor_hint() \
		else GameGlobals.get_enemy_total_count()
	for i in range(total):
		var enemy_tag = TextureRect.new()
		enemy_tag.texture = _enemy_tag_atlas
		enemy_tag.size = Vector2(14, 14)
		_enemy_grid_container.add_child(enemy_tag)

## 从敌人表格中移除一条数据
func _remove_one_from_enemy_grids() -> void:
	_enemy_tank_factory_mutex.lock()
	var children = _enemy_grid_container.get_children()
	if not children.is_empty():
		_enemy_grid_container.remove_child(children[0])
	_enemy_tank_factory_mutex.unlock()

## 清理敌人表格数据
func _clear_enemy_grids_in_container() -> void:
	for enemy_tag in _enemy_grid_container.get_children():
		enemy_tag.queue_free()

## 显示游戏结束的标记
func _show_game_over_tag() -> void:
	_game_over_tag.set_deferred("visible", true)
	var tween = get_tree().create_tween()
	tween.finished.connect(func(): _show_game_over_flinker_effect())
	tween.tween_property(_game_over_tag, "position",\
		Vector2(_game_over_tag.position.x, GameGlobals.GAME_MAP_CONTAINER_SIZE.y / 2.0), 2.0)

## 显示游戏结束 TAG 的效果
func _show_game_over_flinker_effect() -> void:
	var tween = get_tree().create_tween()
	tween.set_loops(6)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.finished.connect(func(): pass)
	tween.tween_property(_game_over_tag, "modulate:a", 0, 0.5)
	tween.tween_property(_game_over_tag, "modulate:a", 1.0, 0.5)

# 生成玩家坦克
func _generate_player_tank() -> void:
	var born_position = Vector2( \
		GameGlobals.GAME_MAP_SIZE.x / 2.0 - 48.0, \
		GameGlobals.GAME_MAP_SIZE.y - 16.0)
	var player_tank = Tank.create( \
		GameEnums.TankType.player, born_position, Vector2.UP)
	player_tank.allow_control = true
	player_tank.set_render_index(100)
	player_tank.set_capabilities([ \
		# CapabilityProperty.Ferry.new(), \
		CapabilityProperty.ProtectClothes.new() ])
	_map_container.add_child(player_tank)
