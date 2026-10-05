extends Node

## 世界边界
const layer_boundary := 1

## 玩家
const layer_player_tank := 2

## 敌人
const layer_enemy_tank := 3

## 玩家子弹
const layer_player_bullet := 4

## 敌人子弹
const layer_enemy_bullet := 5

## 泥墙
const layer_map_tile_mud_wall := 6

## 铁墙/钢墙
const layer_map_tile_steel_wall := 7

## 草场/森林
const layer_map_tile_grass := 8

## 河流
const layer_map_tile_river := 9

## 冰场/湿滑地面
const layer_map_tile_ice := 10

## 玩家总部
const layer_map_tile_master := 11

## 敌方出生基地
const layer_enemy_born_area := 12

## 判断层之间是否发生了碰撞
func is_collision( \
	layer: int, \
	layer_num: int) -> bool:
	return layer & (1 << (layer_num - 1))
