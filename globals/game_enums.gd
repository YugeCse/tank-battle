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
	return "简单" if level == GameLevel.easy\
		 else ( "一般" if level == GameLevel.normal else "困难")

# 地图地砖类型
# 取值：1：水泥墙 2：铁墙 3：草 4：河 5：冰 9：家
enum MapTileType {
	mud_wall = 1,
	steel_wall = 2,
	grass = 3,
	river = 4,
	ice = 5,
	home = 9
}

# 获取所有的地砖类型
const all_map_tile_types: Array[MapTileType] = \
	[MapTileType.mud_wall, \
		MapTileType.steel_wall, \
		MapTileType.grass, \
		MapTileType.river, \
		MapTileType.ice, \
		MapTileType.home]

# 获取地砖对应的文字描述
func get_map_tile_type_description(type: MapTileType) -> String:
	var description = "unknown"
	match type:
		MapTileType.mud_wall:
			description = "泥墙"
		MapTileType.steel_wall:
			description = "铁墙"
		MapTileType.grass:
			description = "草地/森林"
		MapTileType.river:
			description = "河流"
		MapTileType.ice:
			description = "冰块地"
		MapTileType.home:
			description = "营地"
	return description
			
# 坦克类型枚举
enum TankType {
	player,
	enemy,
	enemy1,
	enemy2,
	enemy3,
	enemy4
}

# 获取所有的坦克类型集合
const all_tank_types: Array[TankType] = \
	all_enemy_tank_types + [TankType.player]

# 获取所有的地方坦克类型集合
const all_enemy_tank_types: Array[TankType] = \
	[TankType.enemy, TankType.enemy1, TankType.enemy2, TankType.enemy3]
