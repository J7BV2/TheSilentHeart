class_name ItemDropper
extends Node

const ITEM_PICKUP_SCENE: PackedScene = preload(
	"res://scenes/items/ItemPickup.tscn"
)

@export var drop_distance: float = 0.9
@export var drop_height_offset: float = 0.015

@onready var player: CharacterBody3D = get_parent()
@onready var inventory: PlayerInventory = player.get_node("InventoryComponent")


func drop_selected_item() -> void:
	var item_info := inventory.take_selected()

	if item_info.is_empty():
		return

	var data := item_info["item_data"] as ItemData
	var unique_id := StringName(item_info["unique_id"])

	var session := get_tree().get_first_node_in_group(
		"game_session"
	) as GameSession

	if session == null or session.current_level == null:
		inventory.add_item(data, unique_id)
		return

	var forward := -player.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()

	var candidate := player.global_position + forward * drop_distance

	var drop_position := find_drop_position(candidate)

	if drop_position == Vector3.INF:
		inventory.add_item(data, unique_id)
		return

	var pickup := ITEM_PICKUP_SCENE.instantiate() as WorldItemPickup

	if pickup == null:
		inventory.add_item(data, unique_id)
		return

	pickup.item_data = data
	pickup.unique_instance_id = unique_id

	session.current_level.add_child(pickup)

	pickup.global_position = drop_position
	pickup.global_rotation = Vector3(
		0.0,
		player.global_rotation.y,
		0.0
	)

	# Поворачиваем только визуальную модель.
	pickup.get_node("VisualRoot").rotation_degrees.x = 90.0

	# Запоминаем уникальный ID даже для обычных предметов.
	if unique_id == &"":
		unique_id = StringName(
		"dropped_" + str(Time.get_ticks_usec())
	)

	pickup.unique_instance_id = unique_id
	
	# Сохраняем положение относительно текущей локации.
	var level_transform: Transform3D = (
		session.current_level.global_transform.affine_inverse()
		* pickup.global_transform
	)

	var visual_root := pickup.get_node("VisualRoot") as Node3D

	# Сохраняем состояние предмета.
	ItemRegistry.mark_dropped(
		unique_id,
		session.current_level.level_id,
		data,
		level_transform,
		visual_root.transform
	)


func find_drop_position(candidate: Vector3) -> Vector3:
	var ray_from := Vector3(
		candidate.x,
		player.global_position.y + 2.0,
		candidate.z
	)

	var ray_to := Vector3(
		candidate.x,
		player.global_position.y - 5.0,
		candidate.z
	)

	var query := PhysicsRayQueryParameters3D.create(
		ray_from,
		ray_to,
		1
	)

	query.exclude = [player.get_rid()]
	query.collide_with_areas = false

	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)

	if hit.is_empty():
		return Vector3.INF

	var normal: Vector3 = hit["normal"]

	if normal.y < 0.7:
		return Vector3.INF

	var floor_position: Vector3 = hit["position"]

	return floor_position + Vector3.UP * drop_height_offset
