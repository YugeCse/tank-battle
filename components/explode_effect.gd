extends AnimatedSprite2D

## 爆炸特效
class_name ExplodeEffect

## 是否是大型爆炸
@export
var is_big_explode: bool

func _ready() -> void:
	if not is_big_explode:
		play("default")
	else: play("tank_boom")

func _process(_delta: float) -> void:
	pass

func _on_animation_finished() -> void:
	queue_free() #爆炸完成，从子节点删除

## 创建一个实例
static func create( \
		location: Vector2, \
		big_explode: bool = false, \
) -> ExplodeEffect:
	var instance = (load('res://components/explode_effect.tscn') \
		as PackedScene).instantiate() as ExplodeEffect
	instance.position = location
	instance.is_big_explode = big_explode
	return instance
	
