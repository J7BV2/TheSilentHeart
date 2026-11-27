extends Control

const HP_TEXTURE: Texture2D = preload(
	"res://assets/ui/player/interface/UI_HP.png"
)

@onready var hp_bar: TextureProgressBar = $CenterContainer/Window/Hp

var health_component: PlayerHealth

var fill_tween: Tween
var fade_tween: Tween


func _ready() -> void:

	visible = false
	modulate.a = 0.0

	hp_bar.min_value = 0
	hp_bar.max_value = 100
	hp_bar.value = 100

	hp_bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT

	# Тёмная основа.
	hp_bar.texture_under = HP_TEXTURE
	hp_bar.tint_under = Color(0.18, 0.18, 0.18, 0.9)

	# Белое заполнение.
	hp_bar.texture_progress = HP_TEXTURE
	hp_bar.tint_progress = Color.WHITE
	
	# Скрываем HP при открытии любого игрового окна.
	InterfaceManager.ui_opened.connect(_on_ui_opened)
	InterfaceManager.ui_closed.connect(_on_ui_closed)


func setup(component: PlayerHealth) -> void:

	health_component = component

	if not health_component.health_changed.is_connected(
		_on_health_changed
	):
		health_component.health_changed.connect(
			_on_health_changed
		)

	_on_health_changed(
		health_component.current_health,
		health_component.current_health,
		0
	)


func _on_health_changed(
	current: float,
	_previous: float,
	processed_minutes: int
) -> void:

	# ВСЕГДА обновляем визуальное значение HP.
	# Даже если сейчас открыто другое окно.
	_animate_health(current, processed_minutes)

	# Проверяем, открыто ли сейчас другое окно.
	if is_instance_valid(InterfaceManager.current_ui):

		if fade_tween and fade_tween.is_running():
			fade_tween.kill()

		hide()
		return

	# Показываем шкалу, если здоровье неполное.
	if current < PlayerHealth.MAX_HEALTH:

		if not visible:
			show()
			modulate.a = 0.0

		_fade_to(1.0, 0.25)

	else:

		# Скрываем при полном восстановлении.
		_fade_to(0.0, 0.4, true)


# Плавное изменение заполнения.
func _animate_health(
	target: float,
	processed_minutes: int
) -> void:

	if fill_tween and fill_tween.is_running():
		fill_tween.kill()

	var duration := 0.4

	# При обычном ходе времени анимация
	# соответствует длительности игровой минуты.
	if processed_minutes == 1:

		var manager := get_tree().get_first_node_in_group(
			"time_manager"
		) as TimeManager

		if manager != null:
			duration = manager.real_seconds_per_game_minute

	# При перемотке не ждём реальные часы.
	if target >= PlayerHealth.MAX_HEALTH:
		duration = 0.4

	fill_tween = create_tween()

	fill_tween.tween_property(
		hp_bar,
		"value",
		target,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(
		Tween.EASE_OUT
	)


# Плавное появление и исчезновение.
func _fade_to(
	alpha: float,
	duration: float,
	hide_after: bool = false
) -> void:

	if fade_tween and fade_tween.is_running():
		fade_tween.kill()

	fade_tween = create_tween()

	fade_tween.tween_property(
		self,
		"modulate:a",
		alpha,
		duration
	)

	if hide_after:
		fade_tween.tween_callback(hide)


# Открытие любого интерфейса.
func _on_ui_opened() -> void:

	if fade_tween and fade_tween.is_running():
		fade_tween.kill()

	hide()


# Закрытие интерфейса.
func _on_ui_closed() -> void:

	if health_component == null:
		return

	if health_component.current_health < PlayerHealth.MAX_HEALTH:

		show()
		modulate.a = 0.0

		_fade_to(1.0, 0.25)

	else:

		hide()
		modulate.a = 0.0
