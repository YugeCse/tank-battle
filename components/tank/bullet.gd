extends Area2D

## 子弹对象
class_name Bullet

## 能量，默认 1，3-可以销钢筋,4-可以清理草场
var power: int = 1

## 子弹运行方向
var _run_dir: Vector2

## 子弹的拥有者
var _sender: GameEnums.TankType

## 运行速度
@export
var speed: float = 150

## 子弹精灵
@export
var _bullet_sprite: Sprite2D

## 碰撞矩形
@export
var _collision_shape: CollisionShape2D

## 子弹精灵对应的四个方向的资源集合
@export
var _bullet_sprite_tres: Dictionary[String, AtlasTexture]

func _ready() -> void:
	set_sender(_sender)
	set_run_dir(_run_dir)
	_play_bullet_audio() #播放子弹的相关声音

## 播放子弹的相关声音
func _play_bullet_audio():
	if not GameGlobals.get_music_available(): return
	if _sender == GameEnums.TankType.player:
		$AudioStreamPlayer.stream = load('res://assets/sounds/attack.mp3')
	else: $AudioStreamPlayer.stream = load('res://assets/sounds/bulletCrack.mp3')
	$AudioStreamPlayer.play() #开始播放音频

func _process(delta: float) -> void:
	if _collision_shape.disabled: return
	position += _run_dir * speed * delta

## 设置运行方向
func set_run_dir(dir: Vector2) -> void:
	if dir == Vector2.ZERO: return
	_run_dir = dir
	var dir_name = ''
	match _run_dir:
		Vector2.UP: dir_name = 'up'
		Vector2.DOWN: dir_name = 'down'
		Vector2.LEFT: dir_name = 'left'
		Vector2.RIGHT: dir_name = 'right'
	if dir_name == '': return
	_bullet_sprite.texture = _bullet_sprite_tres[dir_name]
	var shape = RectangleShape2D.new()
	shape.size = _bullet_sprite.texture.get_size()
	_collision_shape.shape = shape

## 获取子弹运行的方向
func get_run_dir() -> Vector2: return _run_dir

## 设置子弹的所属者，发送者
func set_sender(sender: GameEnums.TankType) -> void: 
	_sender = sender #更新私有参数
	if not _sender: return
	if _sender == GameEnums.TankType.player:
		set_collision_layer_value(CollisionLayers.layer_player_bullet, true)
		set_collision_mask_value(CollisionLayers.layer_player_tank, false)
		set_collision_mask_value(CollisionLayers.layer_player_bullet, false)
		return
	set_collision_layer_value(CollisionLayers.layer_enemy_bullet, true)
	set_collision_mask_value(CollisionLayers.layer_enemy_tank, false)
	set_collision_mask_value(CollisionLayers.layer_enemy_bullet, false)

## 设置子弹的所属者，发送者
func get_sender() -> GameEnums.TankType: return _sender

## 碰撞事件检测1
func _on_area_entered(area: Area2D) -> void:
	if area is Bullet: #如果遇到子弹元素，发现类型不同，需要发生碰撞
		var bullet = area as Bullet
		if (bullet.get_sender() == GameEnums.TankType.player and\
				get_sender() != GameEnums.TankType.player) or \
			((bullet.get_sender() != GameEnums.TankType.player and \
				get_sender() == GameEnums.TankType.player)):
			_show_explode_effect()
			bullet._show_explode_effect()

## 碰撞事件检测2
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D: #如果与实体发生了碰撞
		if body is Tank: #如果是坦克类型
			var collide_tank = body as Tank
			var tank_type = collide_tank.get_tank_type()
			var is_attacked = (_sender != GameEnums.TankType.player and \
				tank_type == GameEnums.TankType.player) or \
				(_sender == GameEnums.TankType.player and \
					tank_type != GameEnums.TankType.player)
			if is_attacked: #如果收到伤害
				if not collide_tank.has_protect_clothes():
					_show_explode_effect(false) #子弹发生爆炸
					collide_tank.attacked(power) #执行对应的坦克爆炸
				else: _show_explode_effect(false) #子弹发生爆炸
	elif body is StaticBody2D: #如果与静态物体发生了碰撞
		var c_layer = body.collision_layer
		if CollisionLayers.is_collision(c_layer, CollisionLayers.layer_boundary):
			_show_explode_effect() #显示爆炸效果
		elif CollisionLayers.is_collision(c_layer, CollisionLayers.layer_map_tile_mud_wall):
			body.queue_free() #从节点中删除
			_show_explode_effect() #显示爆炸效果
		elif CollisionLayers.is_collision(c_layer, CollisionLayers.layer_map_tile_steel_wall):
			if power >= 3:
				body.queue_free() #从节点中删除
			_show_explode_effect() #显示爆炸效果
		elif CollisionLayers.is_collision(c_layer, CollisionLayers.layer_map_tile_grass):
			if power >= 4:
				body.queue_free() #从节点中删除
			_show_explode_effect() #显示爆炸效果
		elif CollisionLayers.is_collision(c_layer, CollisionLayers.layer_map_tile_master):
			_show_explode_effect() #显示爆炸效果
			(body as MapTile).set_master_boom_status() #设置玩家总部为爆炸状态

## 显示爆炸效果
func _show_explode_effect(big_explode: bool = false) -> void:
	_collision_shape.set_deferred('disabled', true)
	queue_free() #移除当前节点
	var explode_effect = ExplodeEffect \
		.create(position, big_explode)
	GameGlobals.add_child_to_war_map.emit(explode_effect)

## 创建实例
static func create( \
	location: Vector2, \
	move_dir: Vector2, \
	sender: GameEnums.TankType) -> Bullet:
	var instance = (load('res://components/tank/bullet.tscn') \
		as PackedScene).instantiate() as Bullet
	instance.set_sender(sender)
	instance.set_run_dir(move_dir)
	instance.position = location
	return instance
