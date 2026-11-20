extends Node

var collected_unique_items: Dictionary = {}
var chosen_spawn_options: Dictionary = {}


func reset_for_new_game() -> void:
	collected_unique_items.clear()
	chosen_spawn_options.clear()


func is_collected(unique_id: StringName) -> bool:
	if unique_id == &"":
		return false

	return collected_unique_items.has(unique_id)


func mark_collected(unique_id: StringName) -> void:
	if unique_id == &"":
		return

	collected_unique_items[unique_id] = true


func mark_dropped(unique_id: StringName) -> void:
	if unique_id == &"":
		return

	collected_unique_items.erase(unique_id)


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
