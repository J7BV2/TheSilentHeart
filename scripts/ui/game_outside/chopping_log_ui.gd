extends Control

const LOG_DATA: ItemData = preload(
	"res://resoursces/items/log.tres"
)

const CHOPPED_LOG_DATA: ItemData = preload(
	"res://resoursces/items/logs.tres"
)

const ACTION_SCENE: PackedScene = preload(
	"res://scenes/ui/interactables/Action.tscn"
)


@onready var cell: Button = $CenterContainer/Window/Cell

@onready var confirm_button: Button = \
	$CenterContainer/Window/ConfirmButton

@onready var cancel_button: Button = \
	$CenterContainer/Window/CancelButton

@onready var prompt_label: Label = \
	$CenterContainer/Window/LabelPromt


var inventory: PlayerInventory


func _ready() -> void:

	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

	# Настраиваем иконку внутри Cell.
	cell.expand_icon = false

	cell.add_theme_constant_override(
		"icon_max_width",
		140
	)

	cell.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cell.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER

	_refresh_state()


# Получаем инвентарь от Interactable.
func setup(value: Variant) -> void:

	inventory = value as PlayerInventory

	if inventory == null:
		push_error("ChoppingLog: PlayerInventory не передан!")
		_refresh_state()
		return

	if not inventory.changed.is_connected(_refresh_state):
		inventory.changed.connect(_refresh_state)

	_refresh_state()


# Проверка возможности рубки.
func _can_chop() -> bool:

	if inventory == null:
		return false

	if CHOPPED_LOG_DATA == null:
		return false

	return (
		inventory.has_item(&"axe")
		and inventory.has_item(&"log")
	)


# Обновление двух состояний Cell.
func _refresh_state() -> void:

	if not is_node_ready():
		return

	if inventory == null:

		cell.disabled = true
		cell.icon = null

		confirm_button.disabled = true

		prompt_label.text = "Инвентарь недоступен"

		return

	var missing := PackedStringArray()

	# Проверяем топор.
	if not inventory.has_item(&"axe"):
		missing.append("топор")

	# Проверяем полено.
	if not inventory.has_item(&"log"):
		missing.append("полено")

	if CHOPPED_LOG_DATA == null:
		missing.append("ресурс дров")

	var can_chop := missing.is_empty()

	# Первое состояние: всё имеется.
	if can_chop:

		cell.disabled = false
		cell.icon = LOG_DATA.icon

		confirm_button.disabled = false

		prompt_label.text = ""

	# Второе состояние: чего-то не хватает.
	else:

		cell.disabled = true
		cell.icon = null

		confirm_button.disabled = true

		prompt_label.text = (
			"Не хватает: " + " и ".join(missing)
		)


# Подтверждение рубки.
func _on_confirm_pressed() -> void:

	if not _can_chop():
		_refresh_state()
		return

	# Заменяем полено дровами.
	# Топор остаётся в инвентаре.
	if not inventory.replace_one_item(
		&"log",
		CHOPPED_LOG_DATA
	):
		_refresh_state()
		return

	# Закрываем окно подготовки.
	InterfaceManager.close_ui()

	# Открываем универсальное окно действия.
	InterfaceManager.open_ui(
		ACTION_SCENE,
		{
			"text": "Рубка",
			"duration": 10.0,
			"minutes_to_advance": 20
		}
	)


# Отмена действия.
func _on_cancel_pressed() -> void:

	InterfaceManager.close_ui()
