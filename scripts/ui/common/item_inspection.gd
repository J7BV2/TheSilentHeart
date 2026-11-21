extends Control

@onready var title_label: Label = $Panel/Margin/Content/ItemTitle

@onready var description_label: Label = $Panel/Margin/Content/Description

@onready var preview_pivot: Node3D = $Panel/Margin/Content/PreviewFrame/PreviewContainer/SubViewport/PreviewWorld/PreviewPivot

var dragging: bool = false
var drag_moved: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func setup(data: ItemData) -> void:
	if data == null:
		return

	title_label.text = data.display_name
	description_label.text = data.description

	if data.model_scene == null:
		return

	var model := data.model_scene.instantiate() as Node3D

	if model == null:
		return

	preview_pivot.add_child(model)

	model.scale = data.preview_scale
	model.position = data.preview_offset


func _input(event: InputEvent) -> void:

	# Начало вращения или нажатия для закрытия
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		if event.pressed:
			dragging = true
			drag_moved = false

		else:
			if dragging and not drag_moved:
				InterfaceManager.close_ui()

			dragging = false

			get_viewport().set_input_as_handled()

	# Вращение модели
	elif event is InputEventMouseMotion and dragging:

		if event.relative.length() > 1.0:
			drag_moved = true

			preview_pivot.rotate_y(
				-event.relative.x * 0.01
			)

			var rot := preview_pivot.rotation

			rot.x = clampf(
				rot.x - event.relative.y * 0.01,
				deg_to_rad(-80),
				deg_to_rad(80)
			)

			preview_pivot.rotation = rot

		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		InterfaceManager.close_ui()
		get_viewport().set_input_as_handled()
