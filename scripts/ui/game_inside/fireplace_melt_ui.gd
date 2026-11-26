extends Control

# Предметы.
const TINDER_DATA: ItemData = preload(
	"res://resoursces/items/tinder.tres"
)

const MATCHES_DATA: ItemData = preload(
	"res://resoursces/items/boxOfMatches.tres"
)

const LOGS_DATA: ItemData = preload(
	"res://resoursces/items/logs.tres"
)

const LOG_DATA: ItemData = preload(
	"res://resoursces/items/log.tres"
)

# Универсальная сцена действий.
const ACTION_SCENE: PackedScene = preload(
	"res://scenes/ui/interactables/Action.tscn"
)

# Спички идут первыми, поскольку у них выше шанс розжига.
const IGNITER_OPTIONS = [
	MATCHES_DATA,
	TINDER_DATA
]


# UI.
@onready var igniter_cell: Button = \
	$CenterContainer/Window/IgniterCell

@onready var igniter_left_arrow: Button = \
	$CenterContainer/Window/IgniterLeftArrow

@onready var igniter_right_arrow: Button = \
	$CenterContainer/Window/IgniterRightArrow


@onready var log_cell: Button = \
	$CenterContainer/Window/LogCell

@onready var timber_cell: Button = \
	$CenterContainer/Window/TimberCell


@onready var log_left_arrow: Button = \
	$CenterContainer/Window/LogLeftArrow

@onready var log_right_arrow: Button = \
	$CenterContainer/Window/LogRightArrow

@onready var timber_left_arrow: Button = \
	$CenterContainer/Window/TimberLeftArrow

@onready var timber_right_arrow: Button = \
	$CenterContainer/Window/TimberRightArrow


@onready var confirm_button: Button = \
	$CenterContainer/Window/ConfirmButton

@onready var cancel_button: Button = \
	$CenterContainer/Window/CancelButton


@onready var fire_chance_label: Label = \
	$CenterContainer/Window/FireChanceLabel

@onready var burn_time_label: Label = \
	$CenterContainer/Window/BurnTimeLabel

@onready var chance_label: Label = \
	$CenterContainer/Window/ChanceLabel


# Инвентарь игрока.
var inventory: PlayerInventory = null

# Доступные воспламенители.
var available_igniters: Array[ItemData] = []

# Текущий воспламенитель.
var selected_igniter_index: int = 0

# Выбранное топливо.
var selected_fuel_id: StringName = &""


func _ready() -> void:

	# Подключаем кнопки.
	igniter_left_arrow.pressed.connect(
		_on_igniter_left_pressed
	)

	igniter_right_arrow.pressed.connect(
		_on_igniter_right_pressed
	)

	log_cell.pressed.connect(
		_on_log_cell_pressed
	)

	timber_cell.pressed.connect(
		_on_timber_cell_pressed
	)

	confirm_button.pressed.connect(
		_on_confirm_pressed
	)

	cancel_button.pressed.connect(
		_on_cancel_pressed
	)

	# Ячейки топлива работают как переключатели.
	log_cell.toggle_mode = true
	timber_cell.toggle_mode = true

	# Устанавливаем размеры иконок.
	for cell in [igniter_cell, log_cell, timber_cell]:

		cell.expand_icon = false

		cell.add_theme_constant_override(
			"icon_max_width",
			125
		)

		cell.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER

	# Стрелки топлива пока не нужны:
	# у каждого вида топлива только один вариант.
	log_left_arrow.hide()
	log_right_arrow.hide()

	timber_left_arrow.hide()
	timber_right_arrow.hide()

	# Время горения одинаковое для всех вариантов.
	burn_time_label.text = "40 мин."

	_refresh_ui()


# Получаем инвентарь.
func setup(payload: Variant) -> void:

	inventory = payload as PlayerInventory

	if inventory == null:

		push_error(
			"FireplaceMelt: PlayerInventory не передан!"
		)

		_refresh_ui()
		return

	if not inventory.changed.is_connected(_refresh_ui):

		inventory.changed.connect(_refresh_ui)

	_refresh_ui()


# --------------------------------------------------
# ВОСПЛАМЕНИТЕЛЬ
# --------------------------------------------------

func _refresh_igniters() -> void:

	var previous_id: StringName = &""

	var previous := _get_selected_igniter()

	if previous != null:
		previous_id = previous.item_id

	available_igniters.clear()

	if inventory != null:

		for item_data in IGNITER_OPTIONS:

			if inventory.has_item(item_data.item_id):

				available_igniters.append(item_data)

	# Сохраняем ранее выбранный вариант,
	# если он по-прежнему есть в инвентаре.
	selected_igniter_index = 0

	for i in range(available_igniters.size()):

		if available_igniters[i].item_id == previous_id:

			selected_igniter_index = i
			break

	var has_igniter := not available_igniters.is_empty()

	igniter_cell.disabled = not has_igniter

	igniter_cell.icon = null

	if has_igniter:

		igniter_cell.icon = available_igniters[
			selected_igniter_index
		].icon

	igniter_cell.tooltip_text = (
		"Нет трута или спичек"
		if not has_igniter
		else available_igniters[selected_igniter_index].display_name
	)

	# Стрелки нужны только при наличии двух вариантов.
	var can_switch := available_igniters.size() > 1

	igniter_left_arrow.visible = can_switch
	igniter_right_arrow.visible = can_switch


func _get_selected_igniter() -> ItemData:

	if available_igniters.is_empty():
		return null

	if selected_igniter_index < 0:
		return null

	if selected_igniter_index >= available_igniters.size():
		return null

	return available_igniters[selected_igniter_index]


func _change_igniter(direction: int) -> void:

	var count := available_igniters.size()

	if count <= 1:
		return

	selected_igniter_index = posmod(
		selected_igniter_index + direction,
		count
	)

	_refresh_ui()


func _on_igniter_left_pressed() -> void:

	_change_igniter(-1)


func _on_igniter_right_pressed() -> void:

	_change_igniter(1)


# --------------------------------------------------
# ТОПЛИВО
# --------------------------------------------------

func _refresh_fuel_cells() -> void:

	var has_logs := inventory.has_item(&"logs")
	var has_log := inventory.has_item(&"log")

	log_cell.disabled = not has_logs
	timber_cell.disabled = not has_log

	log_cell.icon = LOGS_DATA.icon if has_logs else null
	timber_cell.icon = LOG_DATA.icon if has_log else null

	# Если выбранный предмет закончился,
	# автоматически выбираем другой.
	if selected_fuel_id == &"logs" and not has_logs:
		selected_fuel_id = &""

	if selected_fuel_id == &"log" and not has_log:
		selected_fuel_id = &""

	if selected_fuel_id == &"":

		if has_logs:
			selected_fuel_id = &"logs"

		elif has_log:
			selected_fuel_id = &"log"

	# Отображаем выбор.
	log_cell.set_pressed_no_signal(
		selected_fuel_id == &"logs"
	)

	timber_cell.set_pressed_no_signal(
		selected_fuel_id == &"log"
	)

	# Дополнительно выделяем активную ячейку.
	log_cell.modulate = (
		Color.WHITE
		if selected_fuel_id == &"logs"
		else Color(0.6, 0.6, 0.6, 1.0)
	)

	timber_cell.modulate = (
		Color.WHITE
		if selected_fuel_id == &"log"
		else Color(0.6, 0.6, 0.6, 1.0)
	)

	log_cell.tooltip_text = (
		"Выбраны дрова"
		if selected_fuel_id == &"logs"
		else "Нажмите, чтобы выбрать дрова"
	) if has_logs else "Нет дров в инвентаре"

	timber_cell.tooltip_text = (
		"Выбрано полено"
		if selected_fuel_id == &"log"
		else "Нажмите, чтобы выбрать полено"
	) if has_log else "Нет полена в инвентаре"


func _on_log_cell_pressed() -> void:

	if not inventory.has_item(&"logs"):
		return

	selected_fuel_id = &"logs"

	_refresh_ui()


func _on_timber_cell_pressed() -> void:

	if not inventory.has_item(&"log"):
		return

	selected_fuel_id = &"log"

	_refresh_ui()


# --------------------------------------------------
# РАСЧЁТ ШАНСА
# --------------------------------------------------

func _get_ignition_chance() -> int:

	var igniter := _get_selected_igniter()

	if igniter == null:
		return -1

	if selected_fuel_id == &"": 
		return -1

	match igniter.item_id:

		&"matches":

			if selected_fuel_id == &"logs":
				return 90

			if selected_fuel_id == &"log":
				return 80

		&"tinder":

			if selected_fuel_id == &"logs":
				return 65

			if selected_fuel_id == &"log":
				return 40

	return -1


# --------------------------------------------------
# ОБНОВЛЕНИЕ ИНТЕРФЕЙСА
# --------------------------------------------------

func _refresh_ui() -> void:

	if not is_node_ready():
		return

	if inventory == null:

		igniter_cell.disabled = true
		igniter_cell.icon = null

		log_cell.disabled = true
		log_cell.icon = null

		timber_cell.disabled = true
		timber_cell.icon = null

		confirm_button.disabled = true

		fire_chance_label.text = "—"
		chance_label.text = "—"
		burn_time_label.text = "40 мин."

		return

	_refresh_igniters()
	_refresh_fuel_cells()

	var chance := _get_ignition_chance()

	if chance >= 0:

		fire_chance_label.text = "%d%%" % chance

		# Пока шанс успеха равен шансу розжига.
		chance_label.text = "%d%%" % chance

	else:

		fire_chance_label.text = "—"
		chance_label.text = "—"

	burn_time_label.text = "40 мин."

	confirm_button.disabled = chance < 0


# --------------------------------------------------
# ПОДТВЕРЖДЕНИЕ
# --------------------------------------------------

func _on_confirm_pressed() -> void:

	if inventory == null:
		return

	var igniter := _get_selected_igniter()
	var chance := _get_ignition_chance()

	if igniter == null or chance < 0:
		_refresh_ui()
		return

	if FireplaceState.is_burning:
		return

	var igniter_id: StringName = igniter.item_id
	var fuel_id: StringName = selected_fuel_id

	# Определяем игровой расход времени.
	var time_cost := 20 if igniter_id == &"matches" else 30

	# Определяем результат попытки.
	var ignition_success := randf_range(0.0, 100.0) < float(chance)

	# Формируем список расходуемых предметов.
	var items_to_consume: Array[StringName] = [
		fuel_id
	]

	# Спички расходуются.
	# Трут остаётся в инвентаре.
	if igniter_id == &"matches":

		items_to_consume.append(&"matches")

	# Проверяем и удаляем предметы.
	if not inventory.consume_items_by_id(items_to_consume):

		_refresh_ui()
		return

	# Подготавливаем универсальное действие.
	var action_payload := {
		"text": "Розжиг",
		"duration": 10.0,
		"minutes_to_advance": time_cost,

		"start_fire_after_action": ignition_success,
		"fire_duration_minutes": 40
	}

	# Закрываем окно подготовки.
	InterfaceManager.close_ui()

	# Запускаем действие.
	InterfaceManager.open_ui(
		ACTION_SCENE,
		action_payload
	)


func _on_cancel_pressed() -> void:

	InterfaceManager.close_ui()
