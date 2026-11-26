extends Control

var action_text: String = "Действие"

var fire_duration_minutes: int = 40
var duration_seconds: float = 10.0
var minutes_to_advance: int = 0

var start_fire_after_action: bool = false
var action_started: bool = false


@onready var action_label: Label = \
	$CenterContainer/Window/Label


func _ready() -> void:

	# Окно должно работать даже при паузе игры.
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	action_label.text = action_text


# Получаем параметры действия.
func setup(payload: Variant) -> void:

	if payload is Dictionary:

		action_text = str(
			payload.get("text", "Действие")
		)

		duration_seconds = maxf(
			float(payload.get("duration", 5.0)),
			0.1
		)

		minutes_to_advance = maxi(
			int(payload.get("minutes_to_advance", 0)),
			0
		)
		start_fire_after_action = bool(
			payload.get("start_fire_after_action", false)
		)

		fire_duration_minutes = maxi(
			int(payload.get("fire_duration_minutes", 40)),
			1
		)
		
	action_label.text = action_text

	_start_action()


# Запуск действия.
func _start_action() -> void:

	if action_started:
		return

	action_started = true

	# Плавное мигание надписи.
	var blink_tween := create_tween()

	blink_tween.set_pause_mode(
		Tween.TWEEN_PAUSE_PROCESS
	)

	blink_tween.set_loops()

	blink_tween.tween_property(
		action_label,
		"modulate:a",
		0.3,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(
		Tween.EASE_IN_OUT
	)

	blink_tween.tween_property(
		action_label,
		"modulate:a",
		1.0,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(
		Tween.EASE_IN_OUT
	)

	# Ждём заданное реальное время.
	# Таймер продолжает работать на паузе.
	await get_tree().create_timer(
		duration_seconds,
		true,
		false,
		true
	).timeout

	# После завершения действия продвигаем игровые часы.
	if minutes_to_advance > 0:

		var time_manager := get_tree().get_first_node_in_group(
			"time_manager"
		) as TimeManager

		if time_manager != null:

			time_manager.advance_minutes(
				minutes_to_advance
			)

		# Если попытка розжига оказалась успешной,
		# включаем постоянное состояние печи.
		if start_fire_after_action:

			FireplaceState.start_fire(
				fire_duration_minutes
			)

		else:

			push_warning(
				"Action: TimeManager не найден!"
			)

	# Останавливаем анимацию.
	blink_tween.kill()

	# Закрываем окно действия.
	if InterfaceManager.current_ui == self:

		InterfaceManager.close_ui()
