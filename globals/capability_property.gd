extends RefCounted

## 能力属性类声明
class_name CapabilityProperty 

## 轮渡能力
class Ferry extends CapabilityProperty:
	func _init() -> void:
		pass

## 休眠状态, 不可移动
class SleepStatus extends CapabilityProperty:
	## 持续时间
	var hold_on_time_sec: float:
		set(value):
			hold_on_time_sec = value
	
	func _init(holdon_time_sec: float = 45.0) -> void:
		self.hold_on_time_sec = holdon_time_sec

## 火力增强
class StrongFire extends CapabilityProperty:
	## 火力等级
	var fire_level: int:
		set(value):
			fire_level = value
	
	## 是否能烧灭草场
	var can_fire_grass: bool:
		get: return fire_level >= 4
	
	func _init(level: int) -> void:
		self.fire_level = level

## 保护衣
class ProtectClothes extends CapabilityProperty:
	
	## 持续时间
	var hold_on_time_sec: float:
		set(value):
			hold_on_time_sec = value
	
	func _init(holdon_time_sec: float = 45.0) -> void:
		self.hold_on_time_sec = holdon_time_sec
