extends Node

signal minute_processed(heat_percent: int)
signal minutes_batch_processed(amount: int)

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

	# Отключаем предыдущий TimeManager.
	if is_instance_valid(time_manager):

		if time_manager.minutes_advanced.is_connected(
			_on_minutes_advanced
		):
			time_manager.minutes_advanced.disconnect(
				_on_minutes_advanced
			)

	# Запоминаем новый TimeManager.
	time_manager = manager

	# Подключаем сигнал, если менеджер существует.
	if is_instance_valid(time_manager):

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

	if amount <= 0:
		return

	var previous_burning := is_burning
	var previous_remaining := remaining_burn_minutes

	# Обрабатываем каждую игровую минуту отдельно.
	for i in range(amount):

		# Сначала определяем тепло.
		var heat := get_heat_output_percent() if is_burning else 0

		# Передаём информацию системе HP.
		minute_processed.emit(heat)

		# Затем расходуем минуту горения.
		if is_burning:

			remaining_burn_minutes = maxi(
				remaining_burn_minutes - 1,
				0
			)

			if remaining_burn_minutes <= 0:
				is_burning = false

	# Обновляем состояние печи.
	if (
		previous_burning != is_burning
		or previous_remaining != remaining_burn_minutes
	):
		state_changed.emit(
			is_burning,
			remaining_burn_minutes
		)

	# Сообщаем, что перемотка обработана.
	minutes_batch_processed.emit(amount)


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
