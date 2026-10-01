@tool
extends Node

# 游戏等级
enum GameLevel {
	easy,
	normal,
	difficult
};

# 获取游戏对应难易程度的文本描述
func get_game_level_descript(level: GameLevel) -> String:
	return "简单" if level == GameLevel.easy else ( "一般" if level == GameLevel.normal else "困难")
