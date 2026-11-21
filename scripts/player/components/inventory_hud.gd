class_name InventoryHUD
extends Control

signal drop_requested

@onready var first_button: Button = $CenterContainer/Window/FirstCellButton
@onready var second_button: Button = $CenterContainer/Window/SecondCellButton
@onready var third_button: Button = $CenterContainer/Window/ThirdCellButton
@onready var drop_button: Button = $CenterContainer/Window/DropButton

var inventory: PlayerInventory
var slot_buttons: Array[Button] = []


func _ready() -> void:
	slot_buttons.append(first_button)
	slot_buttons.append(second_button)
	slot_buttons.append(third_button)

	first_button.pressed.connect(_on_slot_pressed.bind(0))
	second_button.pressed.connect(_on_slot_pressed.bind(1))
	third_button.pressed.connect(_on_slot_pressed.bind(2))

	drop_button.pressed.connect(_on_drop_pressed)

	InterfaceManager.ui_opened.connect(_on_ui_opened)
	InterfaceManager.ui_closed.connect(_on_ui_closed)


func setup(value: PlayerInventory) -> void:
	inventory = value
	inventory.changed.connect(refresh)

	refresh()


func refresh() -> void:
	if inventory == null:
		return

	for i in range(3):
		var item := inventory.slots[i]

		if item != null:
			slot_buttons[i].icon = item.icon
			slot_buttons[i].tooltip_text = item.display_name
		else:
			slot_buttons[i].icon = null
			slot_buttons[i].tooltip_text = ""

		if i == inventory.selected_slot:
			slot_buttons[i].modulate = Color.WHITE
		else:
			slot_buttons[i].modulate = Color(0.65, 0.65, 0.65)

	drop_button.visible = (
		inventory.slots[inventory.selected_slot] != null
	)


func _on_slot_pressed(index: int) -> void:
	if inventory != null:
		inventory.select_slot(index)


func _on_drop_pressed() -> void:
	drop_requested.emit()


func _on_ui_opened() -> void:
	hide()


func _on_ui_closed() -> void:
	show()
