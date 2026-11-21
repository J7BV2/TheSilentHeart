extends Node

var collected_unique_items: Dictionary = {}
var chosen_spawn_options: Dictionary = {}

# Сохранённые предметы в игровых локациях.
var dropped_items: Dictionary = {}


func reset_for_new_game() -> void:
	collected_unique_items.clear()
	chosen_spawn_options.clear()
	dropped_items.clear()


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
