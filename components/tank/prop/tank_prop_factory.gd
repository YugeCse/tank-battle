extends Node2D

## 坦克道具生产工厂
class_name TankPropFactory

## 默认的权重信息
const _DEFAULT_WEIGHTS: Dictionary[GameEnums.TankPropType, int] = {
	GameEnums.TankPropType.timer: 5,
	GameEnums.TankPropType.bomb: 10,
	GameEnums.TankPropType.star: 8,
	GameEnums.TankPropType.hat: 10,
	GameEnums.TankPropType.master_defense: 20,
	GameEnums.TankPropType.reinforcements: 15
}

## 生成道具的权重信息
@export
var _generate_weights: Dictionary[GameEnums.TankPropType, int] = _DEFAULT_WEIGHTS

## 存在的道具
var _exists_prop: TankProp

func _ready() -> void: randomize()

func _process(_delta: float) -> void:
	pass

## 获取已经存在的道具对象
func get_exists_prop() -> TankProp: 
	return _exists_prop

## 生成道具并放置在界面中
func generate_prop() -> void:
	var data_result = _generate_random_prop()
	if not data_result.success: return
	if _exists_prop: #如果道具已经存在了，需要移除已有的
		_exists_prop._on_free_object()
		_exists_prop = null
	var prop_type = data_result.value
	var generate_area = Rect2(Vector2(15, 14), \
		GameGlobals.GAME_MAP_SIZE - Vector2(30, 28))
	var x = randf_range(generate_area.position.x, \
		generate_area.position.x + generate_area.size.x)
	var y = randf_range(generate_area.position.y, \
		generate_area.position.y + generate_area.size.y)
	print('生成道具：{0}, 位置：{1}'.format([GameEnums \
		.get_tank_prop_type_description(prop_type), Vector2(x, y)]))
	var prop = TankProp.create(prop_type, Vector2(x, y))
	_exists_prop = prop #赋值新的道具对象
	add_child(prop) #把道具添加到地图中

## 生成随机道具
func _generate_random_prop() -> DataResult:
	if _generate_weights.is_empty():
		return DataResult.fail("权重表为空")
	var total := 0
	for w in _generate_weights.values():
		if w > 0:
			total += w
	if total <= 0:
		return DataResult.fail("没有有效权重")
	var rand := randi_range(1, total)
	print('prop rand={0}, total-weight={1}' \
		.format([rand, total]))
	var acc := 0
	for key in _generate_weights.keys():
		var weight: int = _generate_weights[key]
		if weight <= 0: continue
		acc += weight
		print('acc={0},weight={1}, key={2}' \
			.format([acc, weight, \
				GameEnums.get_tank_prop_type_description(key)]))
		if rand <= acc:
			return DataResult.ok(key)
	return DataResult.fail("没有道具产生")
