class_name TimeManager
extends Node

signal time_changed(time_text: String)
signal minutes_advanced(amount: int)
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
	process_mode = Node.PROCESS_MODE_PAUSABLE
	time_changed.emit(get_time_string())


func _process(delta: float) -> void:
	if not is_running:
		return

	time_accumulator += delta

	while time_accumulator >= real_seconds_per_game_minute:
		time_accumulator -= real_seconds_per_game_minute

		current_minutes = mini(current_minutes + 1, END_TIME)

		minutes_advanced.emit(1)

		time_changed.emit(get_time_string())

		if current_minutes >= END_TIME:
			is_running = false
			day_finished.emit()
			break


func set_game_time(minutes: int) -> void:

	var previous_minutes := current_minutes

	current_minutes = clampi(
		minutes,
		START_TIME,
		END_TIME
	)

	# Сколько игровых минут действительно прошло.
	var elapsed := maxi(
		current_minutes - previous_minutes,
		0
	)

	# Передаём прошедшее время печи.
	if elapsed > 0:
		minutes_advanced.emit(elapsed)

	time_changed.emit(get_time_string())


func get_time_string() -> String:
	var hours: int = floori(float(current_minutes) / 60.0)
	var minutes: int = current_minutes % 60
	
	return "%02d:%02d" % [hours, minutes]


# Пропуск указанного количества игровых минут.
func advance_minutes(amount: int) -> int:

	if amount <= 0:
		return 0

	if current_minutes >= END_TIME:
		return 0

	var previous_minutes := current_minutes

	current_minutes = mini(
		current_minutes + amount,
		END_TIME
	)

	var advanced := current_minutes - previous_minutes

	time_changed.emit(get_time_string())

	if advanced > 0:
		minutes_advanced.emit(advanced)

	if previous_minutes < END_TIME and current_minutes >= END_TIME:

		is_running = false
		day_finished.emit()

	return advanced
