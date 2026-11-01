extends Area3D

var _last_press_time := 0.0
const PRESS_COOLDOWN := 0.2

func _ready() -> void:
	input_event.connect(_on_input_event)

func _on_input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if _is_press(event):
		get_tree().quit()

func _is_press(event: InputEvent) -> bool:
	var pressed := false

	if event is InputEventMouseButton:
		pressed = event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	elif event is InputEventScreenTouch:
		pressed = event.pressed

	if not pressed:
		return false

	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_press_time < PRESS_COOLDOWN:
		return false

	_last_press_time = now
	return true
