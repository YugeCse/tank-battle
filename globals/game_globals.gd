@tool
extends Node

# 游戏画布的尺寸: 512x448
const GAME_CANVS_SIZE = Vector2(512, 448)

# 游戏地图尺寸：416x416
const GAME_MAP_SIZE = Vector2(416, 416)

# 游戏地图外框：448x448
const GAME_MAP_CONTAINER_SIZE = Vector2(448, 448)

# 游戏默认敌方的总数：20
const DEFAULT_ENEMY_TOTAL_COUNT = 20

# 游戏默认玩家生命总数：3
const DEFAULT_PLAYER_LIFE_COUNT = 3

# 玩家总生命数
var _player_life_count: int = 3

# 敌人总数量
var _enemy_total_count: int = 20

# 当前游戏音乐是否可用
var _music_available: bool = false

# 当前选择的游戏难度
var _game_level: GameEnums.GameLevel = GameEnums.GameLevel.easy

func _ready() -> void:
	_player_life_count = DEFAULT_PLAYER_LIFE_COUNT
	_enemy_total_count = DEFAULT_ENEMY_TOTAL_COUNT

func _process(_delta: float) -> void:
	pass

# 设置玩家生命数
func set_player_life_count(count: int) -> void:
	_player_life_count = count

# 获取玩家生命数
func get_player_life_count() -> int: return _player_life_count

# 增加一条玩家生命数
func increment_one_player_life() -> void:
	_player_life_count += 1

# 设置敌方总人数
func set_enemy_total_count(count: int) -> void:
	_enemy_total_count = count

# 获取敌人的总数量
func get_enemy_total_count() -> int: return _enemy_total_count

# 设置音乐状态是否可用
func set_music_available(available: bool) -> void:
	_music_available = available

# 获取音乐状态是否可用
func get_music_available() -> bool: return _music_available

# 设置游戏难度
func set_game_level(target: GameEnums.GameLevel) -> void:
	_game_level = target

# 获取游戏难度
func get_game_level() -> GameEnums.GameLevel: return _game_level
