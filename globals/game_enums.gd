@tool
extends Node

## 游戏状态枚举
enum GameState {
	idle,
	playing,
	pause,
	game_win,
	game_over
}

## 生命状态枚举
enum LifeState {
	born,
	alive,
	death
}

## 游戏等级
enum GameLevel {
	easy,
	normal,
	difficult
};

## 获取游戏对应难易程度的文本描述
func get_game_level_descript(level: GameLevel) -> String:
	return "简单" if level == GameLevel.easy\
		 else ( "一般" if level == GameLevel.normal else "困难")

## 地图地砖类型
## 取值：1：水泥墙 2：铁墙 3：草 4：河 5：冰 9：家
enum MapTileType {
	mud_wall = 1,
	steel_wall = 2,
	grass = 3,
	river = 4,
	ice = 5,
	home = 9
}

## 获取所有的地砖类型
const all_map_tile_types: Array[MapTileType] = \
	[MapTileType.mud_wall, \
		MapTileType.steel_wall, \
		MapTileType.grass, \
		MapTileType.river, \
		MapTileType.ice, \
		MapTileType.home]

## 获取地砖对应的文字描述
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
			
## 坦克类型枚举
enum TankType {
	player,
	enemy,
	enemy1,
	enemy2,
	enemy3,
	enemy4
}

## 获取所有的坦克类型集合
const all_tank_types: Array[TankType] = \
	all_enemy_tank_types + [TankType.player]

## 获取所有的地方坦克类型集合
const all_enemy_tank_types: Array[TankType] = \
	[TankType.enemy, TankType.enemy1, TankType.enemy2, TankType.enemy3]

## 坦克道具
enum TankPropType {
	## 定时器
	timer,
	## 炸弹
	bomb,
	## 星星
	star,
	## 保护帽
	hat,
	## 总部防御
	master_defense,
	## 增援
	reinforcements,
}

## 根据道具类型获取对应的名称
func get_tank_prop_name(type: TankPropType) -> String:
	match type:
		TankPropType.timer: return 'timer'
		TankPropType.bomb: return 'bomb'
		TankPropType.star: return 'star'
		TankPropType.hat: return 'hat'
		TankPropType.master_defense: return 'master_defense'
		TankPropType.reinforcements: return 'reinforcements'
	push_error('道具类型错误：{0}'.format([type]))
	return ''

## 根据道具类型获取对应的描述信息
func get_tank_prop_type_description(type: TankPropType) -> String:
	match type:
		TankPropType.timer: return '定时器'
		TankPropType.bomb: return '炸弹'
		TankPropType.star: return '五角星'
		TankPropType.hat: return '保护帽'
		TankPropType.master_defense: return '总部防御'
		TankPropType.reinforcements: return '增援'
	push_error('道具类型错误：{0}'.format([type]))
	return ''
