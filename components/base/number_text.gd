@tool
extends Control

class_name NumberText

enum Align { LEFT, CENTER, RIGHT }

@export 
var align: Align = Align.LEFT

@export 
var num_tres: Array[AtlasTexture] = []

@export 
var _number: int = 0:
	set(value):
		_number = value
		_refresh()

var _display_size: Vector2 = Vector2.ZERO

var _display_nums: Array[AtlasTexture] = []

func _ready() -> void:
	_refresh()

func _enter_tree() -> void:
	_refresh()

func _refresh() -> void:
	_preload_resource()
	_display_nums.clear()
	var total_width := 0.0
	var max_height := 0.0
	for n in _parser_int(_number):
		var idx = n.to_int()
		if idx < 0 or idx >= num_tres.size():
			push_warning("num_tres 缺少索引 %d 的纹理" % idx)
			continue
		var tex = num_tres[idx] as AtlasTexture
		if tex == null:
			continue
		var s = tex.get_size()
		total_width += s.x
		max_height = maxf(max_height, s.y)
		_display_nums.append(tex)
	_display_size = Vector2(total_width, max_height)
	# 通知父容器重新计算布局
	custom_minimum_size = _display_size
	queue_redraw()

func _draw() -> void:
	# Control 的绘制原点在左上角，对齐要基于自身 size
	var start_x := 0.0
	match align:
		Align.LEFT:
			start_x = 0.0
		Align.CENTER:
			start_x = (size.x - _display_size.x) * 0.5
		Align.RIGHT:
			start_x = size.x - _display_size.x

	var start_y := (size.y - _display_size.y) * 0.5  # 垂直居中

	var offset_x := start_x
	for tex in _display_nums:
		draw_texture(tex, Vector2(offset_x, start_y))
		offset_x += tex.get_size().x

func set_number(num: int) -> void:
	_number = num  # 通过 setter 自动刷新

func get_number() -> int: return _number

func get_display_size() -> Vector2:
	return _display_size

func _parser_int(num: int) -> Array[String]:
	var result: Array[String] = []
	for c in str(num):
		result.append(c)
	return result

# 预加载资源数据
func _preload_resource() -> void:
	if not (num_tres == null or\
		num_tres.is_empty()):
		return
	num_tres.clear()
	for i in range(0, 10): #循环加载数字资源
		var num_tres_name = \
			"res://assets/textures/ui/nums/num_{0}.tres".format([i])
		num_tres.append(load(num_tres_name) as AtlasTexture)
