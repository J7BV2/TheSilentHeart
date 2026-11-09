class_name GameSession
extends Node3D

const HOUSE_SCENE: PackedScene = preload(
	"res://scenes/game/levels/Game_House.tscn"
)

@onready var player: CharacterBody3D = $Player
@onready var level_container: Node3D = $LevelContainer

var current_level: GameLevel


func _ready() -> void:
	add_to_group("game_session")

	change_location(HOUSE_SCENE, &"PlayerStart")


func change_location(
	packed_scene: PackedScene,
	spawn_name: StringName
) -> bool:

	if packed_scene == null:
		push_error("Сцена локации не назначена!")
		return false

	var new_level := packed_scene.instantiate() as GameLevel

	if new_level == null:
		push_error("Не удалось создать локацию или отсутствует GameLevel!")
		return false

	level_container.add_child(new_level)

	var spawn_path := NodePath(
		"SpawnPoints/" + String(spawn_name)
	)

	var spawn := new_level.get_node_or_null(
		spawn_path
	) as Marker3D

	if spawn == null:
		level_container.remove_child(new_level)
		new_level.queue_free()

		push_error("Не найдена точка появления: " + String(spawn_name))
		return false

	if current_level:
		level_container.remove_child(current_level)
		current_level.queue_free()

	current_level = new_level

	# Перемещаем игрока к точке появления
	player.global_transform = spawn.global_transform
	
	# Меняем размер игрока в зависимости от локации
	player.scale = Vector3.ONE * new_level.player_size

	player.velocity = Vector3.ZERO

	return true
