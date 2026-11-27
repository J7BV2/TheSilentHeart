extends CanvasLayer

var current_ui: Control = null
var was_paused_before_ui: bool = false
var prompt_label: Label = null

var blur_overlay: ColorRect

signal ui_opened
signal ui_closed


func _ready() -> void:
	# Менеджер должен работать даже во время паузы.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Интерфейс будет поверх игрового изображения.
	layer = 20

	blur_overlay = ColorRect.new()
	blur_overlay.name = "BlurOverlay"

	blur_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	blur_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	blur_overlay.process_mode = Node.PROCESS_MODE_ALWAYS

	var shader_material := ShaderMaterial.new()
	shader_material.shader = preload(
		"res://shaders/ui/bed_blur.gdshader"
	)

	blur_overlay.material = shader_material
	blur_overlay.visible = false

	add_child(blur_overlay)

func open_ui(scene: PackedScene, payload: Variant = null) -> void:

	if is_instance_valid(current_ui):
		return

	var ui := scene.instantiate() as Control

	if ui == null:
		push_error("InterfaceManager: корень интерфейса должен быть Control!")
		return

	was_paused_before_ui = get_tree().paused

	current_ui = ui
	ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	blur_overlay.visible = true

	add_child(ui)

	if payload != null and ui.has_method("setup"):
		ui.setup(payload)

	get_tree().paused = true

	ui_opened.emit()

	hide_prompt()

	if not DisplayServer.is_touchscreen_available():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close_ui() -> void:

	if is_instance_valid(current_ui):
		current_ui.queue_free()

	current_ui = null

	blur_overlay.visible = false
	
	# Восстанавливаем предыдущее состояние игры.
	get_tree().paused = was_paused_before_ui

	# Возвращаем захват мыши.
	if not DisplayServer.is_touchscreen_available():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	ui_closed.emit()

func hide_prompt() -> void:
	if prompt_label:
		prompt_label.hide()
