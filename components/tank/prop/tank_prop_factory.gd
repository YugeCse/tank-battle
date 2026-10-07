extends Node2D

## 默认的权重信息
const _DEFAULT_WEIGHTS: Dictionary[GameEnums.TankPropType, int] = {
	GameEnums.TankPropType.timer: 10,
	GameEnums.TankPropType.bomb: 10,
	GameEnums.TankPropType.star: 8,
	GameEnums.TankPropType.hat: 10,
	GameEnums.TankPropType.master_defense: 12,
	GameEnums.TankPropType.reinforcements: 6
}

## 生成道具的权重信息
@export
var _generate_weights: Dictionary[GameEnums.TankPropType, int] = _DEFAULT_WEIGHTS

## 存在的道具
var _exists_prop: TankProp

func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	generate_prop()

func _process(_delta: float) -> void:
	pass

## 生成道具并放置在界面中
func generate_prop() -> void:
	var data_result = _generate_random_prop()
	if not data_result.success: return
	if _exists_prop: #如果道具已经存在了，需要移除已有的
		if is_instance_valid(_exists_prop):
			_exists_prop.queue_free()
		_exists_prop = null
	var prop_type = data_result.success
	var generate_area = Rect2(Vector2(15, 14), \
		GameGlobals.GAME_MAP_SIZE - Vector2(30, 28))
	var x = randf_range(generate_area.position.x, \
		generate_area.position.x + generate_area.size.x)
	var y = randf_range(generate_area.position.y, \
		generate_area.position.y + generate_area.size.y)
	var prop = TankProp.create(prop_type, Vector2(x, y))
	_exists_prop = prop #赋值新的道具对象
	GameGlobals.add_child_to_war_map.emit(prop) #把道具添加到地图中

## 生成随机道具
func _generate_random_prop() -> DataResult:
	var target_type: GameEnums.TankPropType
	var total_weight_num: int = 0
	var total_weight_nums = _generate_weights.values()
	for num in total_weight_nums:
		total_weight_num += num
	for key in _generate_weights.keys():
		var weight = _generate_weights[key]
		var rand = randi_range(1, total_weight_num)
		if rand <= weight: 
			target_type = key
			break
		total_weight_num -= weight
	return DataResult.fail('没有道具产生') if not target_type else DataResult.ok(target_type)
