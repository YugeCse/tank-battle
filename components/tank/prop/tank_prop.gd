extends Area2D

## 道具类
class_name TankProp

## 道具类型
@export
var _type: GameEnums.TankPropType

## 道具精灵sprite对象
@export
var _sprite: Sprite2D

## 碰撞形状
@export
var _collision_shape: CollisionShape2D

func _ready() -> void:
	var timer = Timer.new()
	timer.one_shot = true
	timer.autostart = true
	timer.wait_time = 10.0
	timer.timeout.connect(_show_blink_effect)
	add_child(timer)

func _process(_delta: float) -> void:
	pass

## 设置道具类型
func set_prop_type(type: GameEnums.TankPropType) -> void:
	_type = type
	_sprite.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	var type_name = GameEnums.get_tank_prop_name(type)
	_sprite.texture = load('res://assets/textures/props/prop_{0}.tres'.format([type_name]))

## 获取道具类型
func get_prop_type() -> GameEnums.TankPropType: return _type

## 如果检测到有物体发生碰撞
func _on_body_entered(body: Node2D) -> void:
	if body is Tank:
		var tank = body as Tank
		var tank_type = tank.get_tank_type()
		var can_fetch = tank_type == GameEnums.TankType.player or \
			(tank_type != GameEnums.TankType.player and \
				GameGlobals.get_game_level() == GameEnums.GameLevel.difficult)
		if can_fetch: #如果能拾取道具，则执行道具拾取
			handle_fetched() #处理道具被拾取
			tank.fetch_prop(_type) #处理对应的坦克获得道具

## 添加注销释放对象的定时器
func _add_free_timer(time: float) -> void:
	var timer = Timer.new()
	timer.one_shot = true
	timer.autostart = true
	timer.wait_time = time
	timer.timeout.connect(queue_free)
	add_child(timer)

## 显示闪烁特效
func _show_blink_effect() -> void:
	_add_free_timer(5.0) #5秒后释放对象
	var blink_tween = get_tree().create_tween().set_loops(0)
	blink_tween.tween_property(_sprite, "modulate:a", 0.2, 0.5)
	blink_tween.tween_property(_sprite, "modulate:a", 1.0, 0.5)

## 显示得分记录
func _show_get_score_record() -> void:
	var score_sprite = Sprite2D.new()
	if GameGlobals.get_music_available():
		var audio_player = AudioStreamPlayer.new()
		audio_player.autoplay = true
		if _type != GameEnums.TankPropType.reinforcements:
			audio_player.stream = load('res://assets/sounds/getProp.mp3')
		else: audio_player.stream = load('res://assets/sounds/prop.mp3')
		score_sprite.add_child(audio_player)
	var texture = load('res://assets/textures/ui/score/score_100.tres') as AtlasTexture
	var t_size = texture.get_size()
	score_sprite.texture = texture
	score_sprite.centered = true
	score_sprite.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	score_sprite.global_position = \
		_sprite.global_position - Vector2(t_size.x / 2.0, t_size.y)
	GameGlobals.add_child_to_war_map.emit(score_sprite)
	var dissmiss_tween = get_tree().create_tween().set_loops(1)
	dissmiss_tween.finished.connect(func(): score_sprite.queue_free())
	dissmiss_tween.tween_property(score_sprite, 'modulate:a', 0.0, 2.0)

## 处理道具已经被拾取
func handle_fetched() -> void:
	_collision_shape.set_deferred('disabled', true)
	_show_get_score_record() #显示得分记录
	queue_free() #在下一帧从节点中删除

## 创建一条实例
static func create( \
	type: GameEnums.TankPropType, \
	location: Vector2) -> TankProp:
	var instance = (load('res://components/tank/prop/tank_prop.tscn') \
		as PackedScene).instantiate() as TankProp
	instance.set_prop_type(type)
	instance.position = location
	return instance
