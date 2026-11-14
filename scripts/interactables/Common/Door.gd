extends Interactable

@export_file("*.tscn") var next_scene_path: String = "res://scenes/game/Game_House.tscn"
@export var target_spawn: StringName = &"PlayerStart"

var is_transitioning: bool = false


func get_prompt_text() -> String:
	return "ДВЕРЬ\nНажмите, чтобы открыть"


func can_interact(_actor: Node) -> bool:
	return not is_transitioning


func interact(_actor: Node) -> void:

	if is_transitioning:
		return

	if next_scene_path.is_empty():
		push_error("Door: путь к следующей сцене не указан!")
		return

	var packed_scene := load(next_scene_path) as PackedScene

	if packed_scene == null:
		push_error("Door: не удалось загрузить сцену: " + next_scene_path)
		return

	var session := get_tree().get_first_node_in_group(
		"game_session"
	) as GameSession

	if session == null:
		push_error("Door: Game_Session не найдена!")
		return

	is_transitioning = session.change_location(
		packed_scene,
		target_spawn
	)

	if not is_transitioning:
		push_warning("Door: переход не выполнен!")
