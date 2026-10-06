@tool
extends Node

## 游戏地砖大小：16
const GAME_MAP_TILE_SIZE = 16

## 游戏画布的尺寸: 512x448
const GAME_CANVS_SIZE = Vector2(512, 448)

## 游戏地图尺寸：416x416
const GAME_MAP_SIZE = Vector2(416, 416)

## 游戏地图外框：448x448
const GAME_MAP_CONTAINER_SIZE = Vector2(448, 448)

## 游戏默认敌方的总数：20
const DEFAULT_ENEMY_TOTAL_COUNT = 20

## 默认敌方在地图上的总数量
const DEFAULT_ENEMY_COUNT_IN_MAP = 5

## 游戏默认玩家生命总数：3
const DEFAULT_PLAYER_LIFE_COUNT = 3

## 默认背景颜色
const DEFAULT_BACKGROUND_COLOR = Color("#7e7e7e")

## 添加子节点到地图节点
@warning_ignore('unused_signal')
signal add_child_to_war_map(child: Node2D)

## 游戏状态
var _game_state: GameEnums.GameState = GameEnums.GameState.idle

## 当前关卡
var _stage_level: int = 1

## 玩家总生命数
var _player_life_count: int = 3

## 敌人总数量
var _enemy_total_count: int = 20

## 当前游戏音乐是否可用
var _music_available: bool = false

## 当前选择的游戏难度
var _game_level: GameEnums.GameLevel = GameEnums.GameLevel.easy

## 地图图块数据集合
@onready
var _map_tile_atlas_texture: Dictionary[GameEnums.MapTileType, AtlasTexture] = {
	GameEnums.MapTileType.mud_wall: preload("res://assets/textures/map_tile_mud_wall.tres"),
	GameEnums.MapTileType.steel_wall: preload("res://assets/textures/map_tile_steel_wall.tres"),
	GameEnums.MapTileType.grass: preload("res://assets/textures/map_tile_grass.tres"),
	GameEnums.MapTileType.river: preload("res://assets/textures/map_tile_grass.tres"),
	GameEnums.MapTileType.ice: preload("res://assets/textures/map_tile_ice.tres"),
	GameEnums.MapTileType.home: preload("res://assets/textures/map_tile_player_home.tres")
}

func _ready() -> void:
	_player_life_count = DEFAULT_PLAYER_LIFE_COUNT
	_enemy_total_count = DEFAULT_ENEMY_TOTAL_COUNT

func _process(_delta: float) -> void:
	pass

## 设置游戏状态
func set_game_state(state: GameEnums.GameState):
	_game_state = state

## 获取游戏状态
func get_game_state() -> GameEnums.GameState: return _game_state

## 设置当前的关卡
func set_stage_level(stage: int) -> void:
	_stage_level = stage

## 获取当前的关卡
func get_stage_level() -> int: return _stage_level

## 设置玩家生命数
func set_player_life_count(count: int) -> void:
	_player_life_count = count

## 获取玩家生命数
func get_player_life_count() -> int: return _player_life_count

## 增加一条玩家生命数
func increment_one_player_life() -> void:
	_player_life_count += 1

## 减少一条玩家生命数
func decrement_one_player_life() -> bool:
	if _player_life_count <= 0:
		return false
	_player_life_count -= 1
	return true

## 设置敌方总人数
func set_enemy_total_count(count: int) -> void:
	_enemy_total_count = count

## 获取敌人的总数量
func get_enemy_total_count() -> int: return _enemy_total_count

## 设置音乐状态是否可用
func set_music_available(available: bool) -> void:
	_music_available = available

## 获取音乐状态是否可用
func get_music_available() -> bool: return _music_available

## 设置游戏难度
func set_game_level(target: GameEnums.GameLevel) -> void:
	_game_level = target

## 获取游戏难度
func get_game_level() -> GameEnums.GameLevel: return _game_level

## 根据地块类型，获取对应的资源
func get_map_tile_atlas_texture(type: GameEnums.MapTileType) -> AtlasTexture:
	return _map_tile_atlas_texture[type] as AtlasTexture

## 获取地图数据
func get_map_data(stage: int) -> DataResult:
	var fa = FileAccess.open( \
		"res://assets/stages/map{0}.json".format([stage]), \
		FileAccess.READ)
	if not fa:
		return DataResult.fail("cannot fetch map data")
	var map_json_data = fa.get_as_text()
	fa.close()
	return DataResult.ok(JSON.parse_string(map_json_data))
