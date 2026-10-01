@tool
extends Node2D

# 游戏结束的标记精灵
@export
var _game_over_tag: Sprite2D

# 敌人标志资源
@export
var _enemy_tag_atlas: AtlasTexture

# 敌人表格数据
@export
var _enemy_grid_container: GridContainer

func _ready() -> void:
	_initialize() #初始化方法

func _enter_tree() -> void:
	_initialize() #初始化方法

# 初始化方法
func _initialize() -> void:
	_generate_enemy_grids() #生成敌方表格数据
	get_tree().create_timer(3.0).timeout.connect(func(): _show_game_over_tag())

func _process(_delta: float) -> void:
	pass

# 生成敌方表格数据
func _generate_enemy_grids() -> void:
	_clear_enemy_grids_in_container()
	var total = 20 if Engine.is_editor_hint() \
		else GameGlobals.get_enemy_total_count()
	for i in range(total):
		var enemy_tag = TextureRect.new()
		enemy_tag.texture = _enemy_tag_atlas
		enemy_tag.size = Vector2(14, 14)
		_enemy_grid_container.add_child(enemy_tag)

# 清理敌人表格数据
func _clear_enemy_grids_in_container() -> void:
	for enemy_tag in _enemy_grid_container.get_children():
		enemy_tag.queue_free()

# 显示游戏结束的标记
func _show_game_over_tag() -> void:
	_game_over_tag.set_deferred("visible", true)
	var tween = get_tree().create_tween()
	tween.finished.connect(func(): _show_game_over_flinker_effect())
	tween.tween_property(_game_over_tag, "position",\
		Vector2(_game_over_tag.position.x, GameGlobals.GAME_MAP_CONTAINER_SIZE.y / 2.0), 2.0)

# 显示游戏结束 TAG 的效果
func _show_game_over_flinker_effect() -> void:
	var tween = get_tree().create_tween()
	tween.set_loops(6)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.finished.connect(func(): pass)
	tween.tween_property(_game_over_tag, "modulate:a", 0, 0.5)
	tween.tween_property(_game_over_tag, "modulate:a", 1.0, 0.5)
	
