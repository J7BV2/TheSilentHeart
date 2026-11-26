class_name GameSession
extends Node3D

const HOUSE_SCENE: PackedScene = preload(
	"res://scenes/game/levels/Game_House.tscn"
)

const ITEM_PICKUP_SCENE: PackedScene = preload(
	"res://scenes/items/ItemPickup.tscn"
)

@onready var player: CharacterBody3D = $Player
@onready var level_container: Node3D = $LevelContainer

var current_level: GameLevel


func _ready() -> void:

	ItemRegistry.reset_for_new_game()

	add_to_group("game_session")

	# При создании новой игровой сессии
	# печь изначально выключена.
	FireplaceState.reset_for_new_game()

	# Привязываем менеджер игрового времени.
	FireplaceState.bind_time_manager(
		$TimeManager as TimeManager
	)

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
	
	# Восстанавливаем предметы, которые были выброшены
	# именно в эту локацию.
	_restore_dropped_items(new_level)

	return true

func _restore_dropped_items(level: GameLevel) -> void:

	if level.level_id == &"":
		push_warning(
			"[GameSession] У локации не назначен level_id!"
		)
		return

	var saved_items := ItemRegistry.get_dropped_items_for_level(
		level.level_id
	)

	for item_state in saved_items:

		var data := item_state["item_data"] as ItemData

		if data == null:
			continue

		var pickup := ITEM_PICKUP_SCENE.instantiate() as WorldItemPickup

		if pickup == null:
			continue

		pickup.item_data = data
		pickup.unique_instance_id = item_state["unique_id"]

		# Добавляем предмет в нужную локацию.
		level.add_child(pickup)

		# Восстанавливаем положение и поворот.
		pickup.transform = item_state["level_transform"]

		# Восстанавливаем поворот визуальной модели.
		var visual_root := pickup.get_node("VisualRoot") as Node3D

		visual_root.transform = item_state["visual_transform"]

		print(
			"[GameSession] Восстановлен предмет: ",
			pickup.unique_instance_id,
			" в локации: ",
			level.level_id
		)
