@tool
extends StaticBody2D

## 地砖组件
class_name MapTile

## 玩家总部爆炸完成
signal player_master_explode_finished()

## 地砖的表格坐标
var _grid_coord: Vector2i

## 类型切换定时器
var _switch_type_timer: Timer

## 类型切换计数器
var _switch_type_counter: int = 0

## 切换到铁墙的定时器
var _switch_steel_wall_directly_timer: Timer

## 地砖的碰撞形状
@export
var _collision_shape: CollisionShape2D

## 地砖类型
@export
var _tile_type: GameEnums.MapTileType = GameEnums.MapTileType.mud_wall

func _ready() -> void: pass
	# set_map_title_type(_tile_type)
	# set_collision_layer_value(CollisionLayers.layer_map_tile_mud_wall, false)

func _process(_delta: float) -> void:
	pass

## 设置表格坐标数据
func set_grid_coord(coord: Vector2i) -> void:
	_grid_coord = coord

## 获取表格坐标
func get_grid_coord() -> Vector2i: return _grid_coord

## 设置地砖的类型
func set_map_title_type(type: GameEnums.MapTileType) -> void:
	_tile_type = type # 更新当前的地砖类型
	match type:
		GameEnums.MapTileType.mud_wall:
			set_collision_layer_value(CollisionLayers.layer_map_tile_mud_wall, true)
		GameEnums.MapTileType.steel_wall:
			set_collision_layer_value(CollisionLayers.layer_map_tile_steel_wall, true)
		GameEnums.MapTileType.grass:
			z_index = RenderingServer.CANVAS_ITEM_Z_MAX # 设置尽量大的数据
			set_collision_mask_value(CollisionLayers.layer_player_tank, false)
			set_collision_layer_value(CollisionLayers.layer_map_tile_ice, true)
			set_collision_layer_value(CollisionLayers.layer_map_tile_grass, false)
		GameEnums.MapTileType.river:
			set_collision_layer_value(CollisionLayers.layer_map_tile_river, true)
		GameEnums.MapTileType.ice:
			set_collision_mask_value(CollisionLayers.layer_enemy_tank, false)
			set_collision_mask_value(CollisionLayers.layer_player_tank, false)
			set_collision_layer_value(CollisionLayers.layer_map_tile_ice, true)
		GameEnums.MapTileType.home:
			set_collision_layer_value(CollisionLayers.layer_map_tile_master, true)
	$Sprite2D.texture = GameGlobals.get_map_tile_atlas_texture(type)
	var shape = RectangleShape2D.new()
	shape.size = $Sprite2D.texture.get_size()
	_collision_shape.shape = shape
	_collision_shape.position = shape.size / 2.0
	z_index = 0 if type != GameEnums.MapTileType.grass else RenderingServer.CANVAS_ITEM_Z_MAX

## 获取地砖类型
func get_map_tile_type() -> GameEnums.MapTileType: return _tile_type

## 获取地砖描述信息
func get_map_tile_description() -> String:
	return GameEnums.get_map_tile_type_description(_tile_type)

## 设置碰撞是否可用
func set_collision_available(available: bool) -> void:
	_collision_shape.set_deferred("disabled", !available)

## 获取精灵数据的尺寸大小
func get_sprite_size() -> Vector2: return $Sprite2D.texture.get_size() * scale

## 设置玩家总部爆炸销毁
func set_master_boom_status() -> void:
	set_collision_available(false)
	if GameGlobals.get_music_available():
		var audioStreamPlayer = AudioStreamPlayer.new()
		audioStreamPlayer.autoplay = true
		audioStreamPlayer.stream = \
			load('res://assets/sounds/playerCrack.mp3')
		audioStreamPlayer.finished \
			.connect(func(): audioStreamPlayer.queue_free())
		add_child(audioStreamPlayer)
	player_master_explode_finished.emit() # 玩家爆炸完成事件
	$Sprite2D.texture = load('res://assets/textures/map_tile_player_home_destroy.tres') as AtlasTexture

## 取消类型切换定时器
func dispose_switch_type_timer() -> void:
	if not _switch_type_timer: return
	if not _switch_type_timer.is_stopped():
		_switch_type_timer.stop()
	_switch_type_timer.queue_free()
	_switch_type_timer = null
	_switch_type_counter = 0

## 切换泥墙和铁墙状态
func toggle_steel_wall_to_mud_wall() -> void:
	dispose_switch_steel_wall_directly_timer()
	dispose_switch_type_timer()
	_switch_type_timer = Timer.new()
	_switch_type_timer.wait_time = 0.5
	_switch_type_timer.autostart = true
	_switch_type_timer.one_shot = false
	_switch_type_timer.timeout \
		.connect(_on_switch_map_tile_timer_tick);
	add_child(_switch_type_timer)

## 切换泥墙铁墙逻辑的定时器处理方法
func _on_switch_map_tile_timer_tick() -> void:
	if _switch_type_counter % 2 == 0:
		switch_steel_wall_to_mud_wall()
	else: switch_mud_wall_to_steel_wall()
	if _switch_type_counter >= 12:
		dispose_switch_type_timer()
		return
	_switch_type_counter += 1 #每次计数增加一次
		
## 把泥墙地块变成铁墙地块
func switch_mud_wall_to_steel_wall() -> void:
	set_collision_layer_value( \
		CollisionLayers.layer_map_tile_mud_wall, false)
	set_map_title_type(GameEnums.MapTileType.steel_wall)

## 把铁墙地块变成泥墙地块
func switch_steel_wall_to_mud_wall() -> void:
	set_collision_layer_value( \
		CollisionLayers.layer_map_tile_steel_wall, false)
	set_map_title_type(GameEnums.MapTileType.mud_wall)

## 设置地砖直接变成贴墙的，内部有计算，会在 20s还原成泥墙
func set_map_tile_to_steel_wall_directly() -> void:
	dispose_switch_type_timer()
	set_collision_layer_value( \
		CollisionLayers.layer_map_tile_steel_wall, true)
	set_collision_layer_value( \
		CollisionLayers.layer_map_tile_mud_wall, false)
	set_map_title_type(GameEnums.MapTileType.steel_wall)
	_switch_type_counter = 0
	_switch_steel_wall_directly_timer = Timer.new()
	_switch_steel_wall_directly_timer.wait_time = 20.0
	_switch_steel_wall_directly_timer.one_shot = true
	_switch_steel_wall_directly_timer.autostart = true
	_switch_steel_wall_directly_timer.timeout \
		.connect(toggle_steel_wall_to_mud_wall)
	add_child(_switch_steel_wall_directly_timer)

## 禁用定时器对象
func dispose_switch_steel_wall_directly_timer() -> void:
	if not _switch_steel_wall_directly_timer: return
	if not _switch_steel_wall_directly_timer.is_stopped():
		_switch_steel_wall_directly_timer.stop()
	_switch_steel_wall_directly_timer.queue_free()
	_switch_steel_wall_directly_timer = null

func _exit_tree() -> void:
	dispose_switch_type_timer()
	dispose_switch_steel_wall_directly_timer()

## 创建实例
static func create(location: Vector2) -> MapTile:
	var instance = (load('res://components/map/map_tile.tscn') \
		as PackedScene).instantiate() as MapTile
	instance.position = location
	return instance
