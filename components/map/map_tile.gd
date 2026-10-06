@tool
extends StaticBody2D

## 地砖组件
class_name MapTile

## 地砖的碰撞形状
@export
var _collision_shape: CollisionShape2D

## 地砖类型
@export
var _tile_type: GameEnums.MapTileType = GameEnums.MapTileType.mud_wall

func _ready() -> void:
	set_map_title_type(_tile_type)

func _process(_delta: float) -> void:
	pass
	
## 设置渲染层级
func set_render_index(index: int) -> void:
	$Sprite2D.z_index = index

## 设置地砖的类型
func set_map_title_type(type: GameEnums.MapTileType) -> void:
	_tile_type = type #更新当前的地砖类型
	match type:
		GameEnums.MapTileType.mud_wall:
			set_collision_layer_value(CollisionLayers.layer_map_tile_mud_wall, true)
		GameEnums.MapTileType.steel_wall:
			set_collision_layer_value(CollisionLayers.layer_map_tile_steel_wall, true)
		GameEnums.MapTileType.grass:
			z_index = 99999 #设置尽量大的数据
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
			z_index = 0 #设置默认层为0
			set_collision_layer_value(CollisionLayers.layer_map_tile_master, true)
	$Sprite2D.texture = GameGlobals.get_map_tile_atlas_texture(type)
	
	var shape = RectangleShape2D.new()
	shape.size = $Sprite2D.texture.get_size()
	_collision_shape.shape = shape
	_collision_shape.position = shape.size / 2.0
	z_index = 0 if type == GameEnums.MapTileType.grass else RenderingServer.CANVAS_ITEM_Z_MAX

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
	$Sprite2D.texture = load('res://assets/textures/map_tile_player_home_destroy.tres') as AtlasTexture

## 创建实例
static func create(location: Vector2) -> MapTile:
	var instance = (load('res://components/map/map_tile.tscn') \
		as PackedScene).instantiate() as MapTile
	instance.position = location
	return instance
