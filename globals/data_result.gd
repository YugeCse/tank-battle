extends RefCounted

class_name DataResult

var success: bool

var value: Variant

var error: String

func _init(p_success: bool, p_value: Variant = null, p_error: String = "") -> void:
	success = p_success
	value = p_value
	error = p_error

static func ok(p_value: Variant = null) -> DataResult:
	return DataResult.new(true, p_value)

static func fail(p_error: String) -> DataResult:
	return DataResult.new(false, null, p_error)
