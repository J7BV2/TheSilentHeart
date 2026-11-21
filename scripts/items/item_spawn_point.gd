class_name ItemSpawnPoint
extends Marker3D

const PICKUP_SCENE: PackedScene = preload("res://scenes/items/ItemPickup.tscn")

@export var item_data: ItemData
@export var unique_instance_id: StringName = &""
@export var spawn_option_id: StringName = &""

func _ready() -> void:
	print("[ItemSpawnPoint] Проверяю маркер: ", get_path())

	if item_data == null:
		push_error("[ItemSpawnPoint] Не назначен item_data: " + str(get_path()))
		return

	if unique_instance_id != &"":
		if ItemRegistry.is_collected(unique_instance_id):
			print("[ItemSpawnPoint] Предмет уже подобран: ", unique_instance_id)
			return

		if not item_data.possible_spawn_ids.is_empty():
			if not item_data.possible_spawn_ids.has(String(spawn_option_id)):
				push_error("[ItemSpawnPoint] spawn_option_id '" + String(spawn_option_id) + "' отсутствует в possible_spawn_ids ресурса " + item_data.resource_path)
				return

			var selected := ItemRegistry.choose_spawn_option(
				unique_instance_id,
				item_data.possible_spawn_ids
			)
			print("[ItemSpawnPoint] Выбран вариант: ", selected, "; этот маркер: ", spawn_option_id)
			if selected != String(spawn_option_id):
				return

	_spawn_item()


func _spawn_item() -> void:
	var pickup := PICKUP_SCENE.instantiate() as WorldItemPickup

	if pickup == null:
		push_error("[ItemSpawnPoint] Не удалось создать топор!")
		return

	# Передаём данные предмета
	pickup.item_data = item_data
	pickup.unique_instance_id = unique_instance_id

	# Добавляем предмет в сцену
	get_parent().add_child(pickup)

	# Устанавливаем позицию маркера
	pickup.global_transform = global_transform

	print("========== ПРОВЕРКА ТОПОРА ==========")
	print("Маркер: ", global_position)
	print("Топор: ", pickup.global_position)
	print("Данные предмета: ", pickup.item_data)
	print("Сцена модели: ", pickup.item_data.model_scene)
	print("Дети VisualRoot: ", pickup.get_node("VisualRoot").get_child_count())
	print("=====================================")
