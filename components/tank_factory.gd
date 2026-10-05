@tool
extends Node2D

@export
var born_positions: Array[Vector2]

func _ready() -> void:
	_generate_enemy_tank()

func _process(_delta: float) -> void:
	pass

## 生成敌方的坦克
func _generate_enemy_tank() -> void:
	var born_position = born_positions.pick_random()
	var tank = Tank.create( \
		GameEnums.TankType.enemy, born_position, Vector2.DOWN)
	tank.set_render_index(1000)
	add_child(tank) #添加生成的坦克到子节点
