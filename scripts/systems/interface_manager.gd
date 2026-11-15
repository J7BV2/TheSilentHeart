extends CanvasLayer

var current_ui: Control = null
var was_paused_before_ui: bool = false


func _ready() -> void:
	# Менеджер должен работать даже во время паузы.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Интерфейс будет поверх игрового изображения.
	layer = 20


func open_ui(scene: PackedScene) -> void:

	# Не допускаем открытия нескольких окон одновременно.
	if is_instance_valid(current_ui):
		return

	var ui := scene.instantiate() as Control

	if ui == null:
		push_error("InterfaceManager: корень интерфейса должен быть Control!")
		return

	# Запоминаем состояние игры до открытия интерфейса.
	was_paused_before_ui = get_tree().paused

	current_ui = ui

	# Интерфейс должен продолжать работать на паузе.
	ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	add_child(ui)

	# Останавливаем игровое дерево.
	get_tree().paused = true

	# Показываем мышь на ПК.
	if not DisplayServer.is_touchscreen_available():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close_ui() -> void:

	if is_instance_valid(current_ui):
		current_ui.queue_free()

	current_ui = null

	# Восстанавливаем предыдущее состояние игры.
	get_tree().paused = was_paused_before_ui

	# Возвращаем захват мыши.
	if not DisplayServer.is_touchscreen_available():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
