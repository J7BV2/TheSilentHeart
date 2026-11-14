class_name PlayerInteractor
extends Node3D

signal target_changed(target: Interactable)

@onready var ray: RayCast3D = $"../Camera3D/RayCast3D"
@onready var prompt_label: Label = $"../CanvasLayer/CenterContainer/Label"

var current_interactable: Interactable = null


func _ready() -> void:

	var container := prompt_label.get_parent() as Control

	container.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	prompt_label.add_theme_font_size_override("font_size", 24)
	prompt_label.add_theme_color_override("font_color", Color.WHITE)

	prompt_label.hide()


func _process(_delta: float) -> void:
	_refresh_target()


func _refresh_target() -> void:

	var next_target: Interactable = null

	if ray.is_colliding():

		var collider = ray.get_collider()

		if collider is Interactable:
			next_target = collider as Interactable

	# Изменилась цель
	if current_interactable != next_target:
		current_interactable = next_target
		target_changed.emit(current_interactable)

	# Обновление подсказки
	if is_instance_valid(current_interactable):

		prompt_label.text = current_interactable.get_prompt_text()
		prompt_label.show()

	else:
		current_interactable = null
		prompt_label.hide()


func try_interact(actor: Node) -> bool:

	# Обновляем луч непосредственно перед взаимодействием
	ray.force_raycast_update()
	_refresh_target()

	if not is_instance_valid(current_interactable):
		return false

	if not current_interactable.can_interact(actor):
		return false

	current_interactable.interact(actor)

	return true
