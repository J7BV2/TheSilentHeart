extends Control

# Предметы, которые разрешено добавлять в печь.
# burn_minutes — сколько времени горения добавляет один предмет.

const FUEL_OPTIONS = [
	{
		"item_id": &"logs",
		"data": preload("res://resoursces/items/logs.tres"),
		"burn_minutes": 60
	},
	{
		"item_id": &"log",
		"data": preload("res://resoursces/items/log.tres"),
		"burn_minutes": 40
	}
]


# UI.
@onready var duration_label: Label = \
	$CenterContainer/Window/Duration

@onready var heat_output_label: Label = \
	$CenterContainer/Window/HeatOutput

@onready var cell_button_1: Button = \
	$CenterContainer/Window/CellButton1

@onready var cell_button_2: Button = \
	$CenterContainer/Window/CellButton2

@onready var cell_button_3: Button = \
	$CenterContainer/Window/CellButton3

@onready var confirm_button: Button = \
	$CenterContainer/Window/ConfirmButton

@onready var cancel_button: Button = \
	$CenterContainer/Window/CancelButton


# Инвентарь.
var inventory: PlayerInventory = null

# Выбранное топливо.
var selected_fuel_id: StringName = &""


func _ready() -> void:

	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# Получаем список кнопок.
	var buttons := _get_cell_buttons()

	# Подключаем выбор топлива.
	for i in range(buttons.size()):

		buttons[i].toggle_mode = true

		buttons[i].pressed.connect(
			_on_fuel_cell_pressed.bind(i)
		)

	confirm_button.pressed.connect(
		_on_confirm_pressed
	)

	cancel_button.pressed.connect(
		_on_cancel_pressed
	)

	# Следим за состоянием печи.
	if not FireplaceState.state_changed.is_connected(
		_on_fireplace_state_changed
	):

		FireplaceState.state_changed.connect(
			_on_fireplace_state_changed
		)

	_refresh_ui()


func setup(payload: Variant) -> void:

	inventory = payload as PlayerInventory

	if inventory == null:

		push_error(
			"FireplaceAdd: PlayerInventory не передан!"
		)

		_refresh_ui()
		return

	if not inventory.changed.is_connected(_refresh_ui):

		inventory.changed.connect(_refresh_ui)

	_refresh_ui()


func _exit_tree() -> void:

	if inventory != null and is_instance_valid(inventory):

		if inventory.changed.is_connected(_refresh_ui):
			inventory.changed.disconnect(_refresh_ui)

	if FireplaceState.state_changed.is_connected(
		_on_fireplace_state_changed
	):

		FireplaceState.state_changed.disconnect(
			_on_fireplace_state_changed
		)


# --------------------------------------------------
# КНОПКИ ЯЧЕЕК
# --------------------------------------------------

func _get_cell_buttons() -> Array[Button]:

	return [
		cell_button_1,
		cell_button_2,
		cell_button_3
	]


func _on_fuel_cell_pressed(index: int) -> void:

	if inventory == null:
		return

	if index < 0 or index >= FUEL_OPTIONS.size():
		return

	var option: Dictionary = FUEL_OPTIONS[index]

	var item_id: StringName = option["item_id"]

	# Проверяем, что предмет всё ещё имеется.
	if not inventory.has_item(item_id):

		_refresh_ui()
		return

	selected_fuel_id = item_id

	_refresh_ui()


# --------------------------------------------------
# ОБНОВЛЕНИЕ ЯЧЕЕК
# --------------------------------------------------

func _refresh_cells() -> void:

	var buttons := _get_cell_buttons()

	# Если ранее выбранный предмет закончился,
	# отменяем его выбор.
	if inventory == null:

		selected_fuel_id = &""

	elif (
		selected_fuel_id != &""
		and not inventory.has_item(selected_fuel_id)
	):

		selected_fuel_id = &""

	for i in range(buttons.size()):

		var button := buttons[i]

		# В будущем сюда можно добавить другие виды топлива.
		if i >= FUEL_OPTIONS.size():

			button.visible = false
			button.disabled = true
			continue

		var option: Dictionary = FUEL_OPTIONS[i]

		var item_id: StringName = option["item_id"]

		var item_data := option["data"] as ItemData

		var added_minutes: int = option["burn_minutes"]

		var available := (
			inventory != null
			and inventory.has_item(item_id)
		)

		# Показываем только предметы из инвентаря.
		button.visible = available
		button.disabled = not available

		if not available:

			button.text = ""
			button.set_pressed_no_signal(false)
			continue

		button.text = "%s\n+%s" % [
			item_data.display_name,
			_format_duration(added_minutes)
		]

		# Выделяем выбранный предмет.
		button.set_pressed_no_signal(
			selected_fuel_id == item_id
		)


# --------------------------------------------------
# ПОДТВЕРЖДЕНИЕ
# --------------------------------------------------

func _get_selected_option() -> Dictionary:

	for option in FUEL_OPTIONS:

		if option["item_id"] == selected_fuel_id:
			return option

	return {}


func _on_confirm_pressed() -> void:

	if inventory == null:
		return

	if not FireplaceState.is_burning:
		_refresh_ui()
		return

	var option := _get_selected_option()

	if option.is_empty():
		return

	var item_id: StringName = option["item_id"]

	var added_minutes: int = option["burn_minutes"]

	# Повторная проверка наличия предмета.
	if not inventory.has_item(item_id):

		_refresh_ui()
		return

	# Удаляем один экземпляр топлива.
	var items_to_consume: Array[StringName] = [
		item_id
	]

	if not inventory.consume_items_by_id(items_to_consume):

		_refresh_ui()
		return

	# Добавляем время горения.
	FireplaceState.add_burn_time(
		added_minutes
	)

	# Снимаем выделение.
	selected_fuel_id = &""

	# Обновляем интерфейс.
	_refresh_ui()


# --------------------------------------------------
# ОТОБРАЖЕНИЕ
# --------------------------------------------------

func _refresh_ui() -> void:

	if not is_node_ready():
		return

	var remaining := FireplaceState.remaining_burn_minutes

	# Оставшееся время.
	duration_label.text = _format_duration(remaining)

	# Теплоотдача.
	heat_output_label.text = "%d%%" % (
		FireplaceState.get_heat_output_percent()
	)

	# Обновляем ячейки.
	_refresh_cells()

	# Подтверждение возможно только если:
	# - печь горит;
	# - есть инвентарь;
	# - выбрано топливо;
	# - предмет имеется в инвентаре.

	var can_add := (
		inventory != null
		and FireplaceState.is_burning
		and selected_fuel_id != &""
		and inventory.has_item(selected_fuel_id)
	)

	confirm_button.disabled = not can_add


func _on_fireplace_state_changed(
	_is_burning: bool,
	_remaining_minutes: int
) -> void:

	_refresh_ui()


# --------------------------------------------------
# ФОРМАТИРОВАНИЕ ВРЕМЕНИ
# --------------------------------------------------

func _format_duration(total_minutes: int) -> String:

	if total_minutes <= 0:
		return "0 мин."

	var hours := floori(
		float(total_minutes) / 60.0
	)

	var minutes := total_minutes % 60

	if hours > 0 and minutes > 0:

		return "%d ч. %d мин." % [
			hours,
			minutes
		]

	if hours > 0:

		return "%d ч." % hours

	return "%d мин." % minutes


# --------------------------------------------------
# ОТМЕНА
# --------------------------------------------------

func _on_cancel_pressed() -> void:

	InterfaceManager.close_ui()
