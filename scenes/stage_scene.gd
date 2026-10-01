@tool
extends Node2D

@export
var stage_num_text: NumberText

func _ready() -> void:
	set_process_input(true)

func _input(event: InputEvent) -> void:
	var cur_stage = stage_num_text.get_number()
	if _is_key_just_pressed(event, KEY_J) or\
		_is_key_just_pressed(event, KEY_UP):
		cur_stage += 1
	elif _is_key_just_pressed(event, KEY_K) or\
		_is_key_just_pressed(event, KEY_DOWN):
		cur_stage -= 1
	if cur_stage < 1:
		cur_stage = 21
	elif cur_stage > 21:
		cur_stage = 1
	stage_num_text.set_number(cur_stage)
	
func _is_key_just_pressed(event: InputEvent, key_code: int):
	return event is InputEventKey and\
		not event.is_echo() and\
		event.is_pressed() and\
		event.physical_keycode == key_code
