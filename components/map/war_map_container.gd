@tool
extends Node2D

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, GameGlobals.GAME_MAP_SIZE), Color.BLACK)
