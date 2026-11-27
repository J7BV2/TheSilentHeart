class_name PlayerHealth
extends Node

signal health_changed(
	current_health: float,
	previous_health: float,
	processed_minutes: int
)

signal died


const MAX_HEALTH := 100.0

const OUTSIDE_DRAIN_PER_MINUTE := MAX_HEALTH / 60.0
const HOUSE_COLD_DRAIN_PER_MINUTE := MAX_HEALTH / 120.0

# При 100% тепла 25 HP -> 100 HP за 20 минут.
const MAX_HEAL_PER_MINUTE := 75.0 / 20.0


var current_health: float = MAX_HEALTH
var is_dead: bool = false

# Для объединения обновлений интерфейса
# после обычного течения времени или перемотки.
var batch_start_health: float = MAX_HEALTH
var batch_minutes: int = 0


func _ready() -> void:

	FireplaceState.minute_processed.connect(
		_on_minute_processed
	)

	FireplaceState.minutes_batch_processed.connect(
		_on_minutes_batch_processed
	)


func _exit_tree() -> void:

	if FireplaceState.minute_processed.is_connected(
		_on_minute_processed
	):
		FireplaceState.minute_processed.disconnect(
			_on_minute_processed
		)

	if FireplaceState.minutes_batch_processed.is_connected(
		_on_minutes_batch_processed
	):
		FireplaceState.minutes_batch_processed.disconnect(
			_on_minutes_batch_processed
		)


# Определяем текущую локацию.
func _get_location_id() -> StringName:

	var session := get_tree().get_first_node_in_group(
		"game_session"
	) as GameSession

	if session == null or session.current_level == null:
		return &""

	return session.current_level.level_id


# Обработка одной игровой минуты.
func _on_minute_processed(heat_percent: int) -> void:

	if batch_minutes == 0:
		batch_start_health = current_health

	batch_minutes += 1

	if is_dead:
		return

	var location_id := _get_location_id()

	match location_id:

		&"game_outside":

			_change_health(
				-OUTSIDE_DRAIN_PER_MINUTE
			)

		&"game_house":

			if heat_percent > 0:

				var healing := (
					MAX_HEAL_PER_MINUTE
					* float(heat_percent) / 100.0
				)

				_change_health(healing)

			else:

				_change_health(
					-HOUSE_COLD_DRAIN_PER_MINUTE
				)


# Изменение HP.
func _change_health(amount: float) -> void:

	if is_dead:
		return

	current_health = clampf(
		current_health + amount,
		0.0,
		MAX_HEALTH
	)

	if current_health <= 0.0:

		is_dead = true
		died.emit()


# Обновляем UI после обработки всей перемотки.
func _on_minutes_batch_processed(
	_amount: int
) -> void:

	if batch_minutes <= 0:
		return

	if not is_equal_approx(
		current_health,
		batch_start_health
	):

		health_changed.emit(
			current_health,
			batch_start_health,
			batch_minutes
		)

	batch_minutes = 0
	batch_start_health = current_health


# Сброс при начале новой игры.
func reset_for_new_game() -> void:

	var previous := current_health

	current_health = MAX_HEALTH

	is_dead = false
	batch_minutes = 0
	batch_start_health = MAX_HEALTH

	health_changed.emit(
		current_health,
		previous,
		0
	)
