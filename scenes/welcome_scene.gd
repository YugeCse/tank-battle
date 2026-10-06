@tool
extends Node2D

## 游戏设置弹窗
@export
var _settings_popup: Popup

## 音乐选择框对象
@export
var _music_checkbox: CheckBox

## 游戏难度-"简单"选择框
@export
var _game_easy_checkbox: CheckBox

## 游戏难度-"一般"选择框
@export
var _game_normal_checkbox: CheckBox

## 游戏难度-"困难"选择框
@export
var _game_difficult_checkbox: CheckBox

func _ready() -> void:
	_settings_popup.visible = false
	_music_checkbox.set_pressed_no_signal(\
		GameGlobals.get_music_available())
	var global_game_level = GameGlobals.get_game_level()
	if global_game_level == GameEnums.GameLevel.easy:
		_toggle_game_level(GameEnums.GameLevel.easy, true)
	elif global_game_level == GameEnums.GameLevel.normal:
		_toggle_game_level(GameEnums.GameLevel.normal)
	else: _toggle_game_level(GameEnums.GameLevel.difficult)
	_game_easy_checkbox.toggled\
		.connect(func(on): _on_toggle_game_level(on, GameEnums.GameLevel.easy))
	_game_normal_checkbox.toggled\
		.connect(func(on): _on_toggle_game_level(on, GameEnums.GameLevel.normal))
	_game_difficult_checkbox.toggled\
		.connect(func(on): _on_toggle_game_level(on, GameEnums.GameLevel.difficult))

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	if not _settings_popup.visible:
		if Input.is_action_just_pressed(&'ui_accept'):
			_on_start_game_button_click()
		elif Input.is_action_just_pressed(&'ui_menu'):
			_on_settings_button_click()

## 游戏设置按钮点击事件
func _on_settings_button_click() -> void:
	_settings_popup.show()

## 开始游戏按钮点击事件
func _on_start_game_button_click() -> void:
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")

## 弹窗关闭按钮
func _on_dialog_close_button_click() -> void:
	_settings_popup.hide()

## 游戏音乐选择切换
func _on_music_check_box_toggled(toggled_on: bool) -> void:
	GameGlobals.set_music_available(toggled_on)
	print('音乐播放状态：', '打开' if(toggled_on) else '关闭')

## 响应游戏难易选择的Checkbox的事件
func _on_toggle_game_level(toggled_on: bool, target: GameEnums.GameLevel) -> void:
	if(not toggled_on): return
	_toggle_game_level(target, false)
	print('你已选择了游戏难度：{0}'.format([GameEnums.get_game_level_descript(target)]))

## 切换游戏难度
func _toggle_game_level(target: GameEnums.GameLevel, no_signal: bool = false) -> void:
	if target == GameEnums.GameLevel.easy:
		if not no_signal:
			_game_easy_checkbox.button_pressed = true
		else: _game_easy_checkbox.set_pressed_no_signal(true)
		_game_normal_checkbox.set_pressed_no_signal(false)
		_game_difficult_checkbox.set_pressed_no_signal(false)
	elif target == GameEnums.GameLevel.normal:
		_game_easy_checkbox.set_pressed_no_signal(false)
		if not no_signal:
			_game_normal_checkbox.set_pressed_no_signal(true)
		else: _game_normal_checkbox.button_pressed = true
		_game_difficult_checkbox.set_pressed_no_signal(false)
	else:
		_game_easy_checkbox.set_pressed_no_signal(false)
		_game_normal_checkbox.set_pressed_no_signal(false)
		if not no_signal:
			_game_difficult_checkbox.set_pressed_no_signal(true)
		else: _game_difficult_checkbox.button_pressed = true
