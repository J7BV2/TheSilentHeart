extends Node

signal state_changed(
	is_burning: bool,
	remaining_minutes: int
)

var is_burning: bool = false
var remaining_burn_minutes: int = 0

var time_manager: TimeManager = null


# Вызывается при начале новой игровой сессии.
func reset_for_new_game() -> void:

	is_burning = false
	remaining_burn_minutes = 0

	state_changed.emit(
		is_burning,
		remaining_burn_minutes
	)


# Подключаем менеджер игрового времени.
func bind_time_manager(manager: TimeManager) -> void:

	if time_manager != null:

		if time_manager.minutes_advanced.is_connected(
			_on_minutes_advanced
		):
			time_manager.minutes_advanced.disconnect(
				_on_minutes_advanced
			)

	time_manager = manager

	if time_manager != null:

		if not time_manager.minutes_advanced.is_connected(
			_on_minutes_advanced
		):
			time_manager.minutes_advanced.connect(
				_on_minutes_advanced
			)


# Успешный розжиг.
func start_fire(duration_minutes: int = 40) -> void:

	is_burning = true

	remaining_burn_minutes = maxi(
		duration_minutes,
		1
	)

	state_changed.emit(
		is_burning,
		remaining_burn_minutes
	)


# Уменьшение времени горения.
func _on_minutes_advanced(amount: int) -> void:

	if not is_burning:
		return

	remaining_burn_minutes = maxi(
		remaining_burn_minutes - amount,
		0
	)

	if remaining_burn_minutes <= 0:

		is_burning = false

		print("Огонь в печи погас.")

	state_changed.emit(
		is_burning,
		remaining_burn_minutes
	)


# Добавление топлива в уже горящую печь.
func add_burn_time(minutes: int) -> bool:

	if not is_burning or minutes <= 0:
		return false

	remaining_burn_minutes += minutes

	state_changed.emit(
		is_burning,
		remaining_burn_minutes
	)

	return true


# Теплоотдача от 0 до 100%.
func get_heat_output_percent() -> int:

	if not is_burning:
		return 0

	var heat := clampf(
		float(remaining_burn_minutes) / 80.0,
		0.0,
		1.0
	)

	return roundi(heat * 100.0)
