class_name PlayerCameraController
extends Node

@export var mouse_sensitivity: float = 0.002

@export var min_pitch: float = -89.0
@export var max_pitch: float = 89.0

@onready var player: CharacterBody3D = get_parent() as CharacterBody3D
@onready var camera: Camera3D = $"../Camera3D"

var camera_pitch: float = 0.0


func _unhandled_input(event: InputEvent) -> void:

	if not (event is InputEventMouseMotion):
		return

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	# Горизонтальный поворот игрока
	player.rotate_y(-event.relative.x * mouse_sensitivity)

	# Вертикальный поворот камеры
	camera_pitch -= event.relative.y * mouse_sensitivity

	camera_pitch = clampf(
		camera_pitch,
		deg_to_rad(min_pitch),
		deg_to_rad(max_pitch)
	)

	camera.rotation.x = camera_pitch
