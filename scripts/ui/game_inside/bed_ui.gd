extends Control

var selected_minutes: int = 8 * 60
var step_minutes: int = 1

@onready var time_label: Label = $CenterContainer/Window/TimeLabel
@onready var left_arrow: Button = $CenterContainer/Window/LeftArrow
@onready var right_arrow: Button = $CenterContainer/Window/RightArrow

@onready var step_1_button: Button = $CenterContainer/Window/Step1Button
@onready var step_10_button: Button = $CenterContainer/Window/Step10Button
@onready var step_60_button: Button = $CenterContainer/Window/Step60Button

@onready var confirm_button: Button = $CenterContainer/Window/ConfirmButton
@onready var cancel_button: Button = $CenterContainer/Window/CancelButton


func _ready() -> void:
	
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	confirm_button.pressed.connect(_on_confirm_pressed)
	var time_manager := get_tree().get_first_node_in_group(
		"time_manager"
	) as TimeManager

	if time_manager == null:
		push_error("Bed UI: TimeManager не найден!")
		return

	# Начинаем выбор с текущего игрового времени.
	selected_minutes = time_manager.current_minutes

	left_arrow.pressed.connect(_on_left_arrow_pressed)
	right_arrow.pressed.connect(_on_right_arrow_pressed)

	step_1_button.pressed.connect(_on_step_1_pressed)
	step_10_button.pressed.connect(_on_step_10_pressed)
	step_60_button.pressed.connect(_on_step_60_pressed)

	cancel_button.pressed.connect(_on_cancel_pressed)

	_update_time_label()


func _on_left_arrow_pressed() -> void:
	_change_time(-step_minutes)


func _on_right_arrow_pressed() -> void:
	_change_time(step_minutes)


func _on_step_1_pressed() -> void:
	step_minutes = 1


func _on_step_10_pressed() -> void:
	step_minutes = 10


func _on_step_60_pressed() -> void:
	step_minutes = 60


func _change_time(amount: int) -> void:

	var time_manager := get_tree().get_first_node_in_group(
		"time_manager"
	) as TimeManager

	if time_manager == null:
		return

	selected_minutes = clampi(
		selected_minutes + amount,
		time_manager.current_minutes,
		TimeManager.END_TIME
	)

	_update_time_label()


func _update_time_label() -> void:

	var hours := floori(float(selected_minutes) / 60.0)
	var minutes := selected_minutes % 60

	time_label.text = "%02d:%02d" % [hours, minutes]


func _on_cancel_pressed() -> void:
	InterfaceManager.close_ui()
	
	
func _on_confirm_pressed() -> void:

	var time_manager := get_tree().get_first_node_in_group(
		"time_manager"
	) as TimeManager

	if time_manager == null:
		return

	# Дополнительная защита от перемотки назад.
	if selected_minutes <= time_manager.current_minutes:
		return

	time_manager.set_game_time(selected_minutes)

	InterfaceManager.close_ui()


func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("ui_cancel"):
		InterfaceManager.close_ui()
		get_viewport().set_input_as_handled()
