extends Node

var _music_available: bool = false

var _game_level: GameEnums.GameLevel = GameEnums.GameLevel.easy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# 设置音乐状态是否可用
func set_music_available(available: bool) -> void:
	_music_available = available

# 获取音乐状态是否可用
func get_music_available() -> bool:
	return _music_available

# 设置游戏难度
func set_game_level(target: GameEnums.GameLevel) -> void:
	_game_level = target

# 获取游戏难度
func get_game_level() -> GameEnums.GameLevel:
	return _game_level
