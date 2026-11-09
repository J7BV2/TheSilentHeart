class_name TimeManager
extends Node

signal time_changed(time_text: String)
signal day_finished

const START_TIME := 8 * 60
const END_TIME := 20 * 60

# Сколько реальных секунд занимает одна игровая минута
@export_range(0.1, 60.0, 0.1)
var real_seconds_per_game_minute: float = 24.0

var current_minutes: int = START_TIME
var time_accumulator: float = 0.0
var is_running: bool = true


func _enter_tree() -> void:
	add_to_group("time_manager")


func _ready() -> void:
	time_changed.emit(get_time_string())


func _process(delta: float) -> void:
	if not is_running:
		return

	time_accumulator += delta

	while time_accumulator >= real_seconds_per_game_minute:
		time_accumulator -= real_seconds_per_game_minute

		current_minutes = mini(current_minutes + 1, END_TIME)

		time_changed.emit(get_time_string())

		if current_minutes >= END_TIME:
			is_running = false
			day_finished.emit()
			break


func get_time_string() -> String:
	var hours: int = floori(float(current_minutes) / 60.0)
	var minutes: int = current_minutes % 60

	return "%02d:%02d" % [hours, minutes]
