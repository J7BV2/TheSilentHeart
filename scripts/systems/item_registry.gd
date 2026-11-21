extends Node

var collected_unique_items: Dictionary = {}
var chosen_spawn_options: Dictionary = {}

# Количество уже взятых поленьев из источников.
var harvested_source_counts: Dictionary = {}

# Сохранённые предметы в игровых локациях.
var dropped_items: Dictionary = {}


func reset_for_new_game() -> void:
	collected_unique_items.clear()
	chosen_spawn_options.clear()
	dropped_items.clear()
	harvested_source_counts.clear()


func is_collected(unique_id: StringName) -> bool:
	if unique_id == &"":
		return false

	return collected_unique_items.has(unique_id)


func has_dropped_item(unique_id: StringName) -> bool:
	if unique_id == &"":
		return false

	return dropped_items.has(unique_id)


func mark_collected(unique_id: StringName) -> void:
	if unique_id == &"":
		return

	# Убираем сохранённое положение предмета.
	dropped_items.erase(unique_id)

	collected_unique_items[unique_id] = true


func mark_dropped(
	unique_id: StringName,
	level_id: StringName,
	item_data: ItemData,
	level_transform: Transform3D,
	visual_transform: Transform3D
) -> void:

	if unique_id == &"":
		return

	collected_unique_items.erase(unique_id)

	dropped_items[unique_id] = {
		"level_id": level_id,
		"item_data": item_data,
		"level_transform": level_transform,
		"visual_transform": visual_transform
	}


func get_dropped_items_for_level(level_id: StringName) -> Array:

	var result: Array = []

	for unique_id in dropped_items.keys():

		var state: Dictionary = dropped_items[unique_id]

		if state["level_id"] == level_id:

			result.append({
				"unique_id": unique_id,
				"item_data": state["item_data"],
				"level_transform": state["level_transform"],
				"visual_transform": state["visual_transform"]
			})

	return result


func choose_spawn_option(
	unique_id: StringName,
	options: PackedStringArray
) -> String:

	if unique_id == &"" or options.is_empty():
		return ""

	if not chosen_spawn_options.has(unique_id):
		var random_index := randi_range(0, options.size() - 1)
		chosen_spawn_options[unique_id] = options[random_index]

	return String(chosen_spawn_options[unique_id])


# Сколько предметов уже взяли из конкретного источника.
func get_harvested_count(source_id: StringName) -> int:

	return int(harvested_source_counts.get(source_id, 0))


# Сохраняем новое количество взятых предметов.
func set_harvested_count(
	source_id: StringName,
	count: int
) -> void:

	if source_id == &"":
		return

	harvested_source_counts[source_id] = maxi(count, 0)
