class_name PlayerMovementController
extends Node

@export var walk_speed: float = 3.0
@export var run_speed: float = 5.0
@export var gravity: float = 9.8

var player: CharacterBody3D


func _ready() -> void:
	player = get_parent() as CharacterBody3D


func physics_update(delta: float) -> void:

	if player == null:
		return

	# Гравитация
	if not player.is_on_floor():
		player.velocity.y -= gravity * delta
	else:
		player.velocity.y = 0.0

	# Получаем направление из Input Map
	var input_dir := Input.get_vector(
		&"move_left",
		&"move_right",
		&"move_forward",
		&"move_back"
	)

	# Переводим направление в мировые координаты игрока
	var direction := player.global_transform.basis * Vector3(
		input_dir.x, 0.0, input_dir.y
	)

	direction.y = 0.0
	direction = direction.normalized()

	# Выбор скорости
	var speed := walk_speed

	if Input.is_action_pressed(&"run"):
		speed = run_speed

	# Передвижение
	if direction.length_squared() > 0.0:
		player.velocity.x = direction.x * speed
		player.velocity.z = direction.z * speed
	else:
		player.velocity.x = move_toward(
			player.velocity.x, 0.0, walk_speed * 8.0 * delta
		)
		player.velocity.z = move_toward(
			player.velocity.z, 0.0, walk_speed * 8.0 * delta
		)

	player.move_and_slide()
