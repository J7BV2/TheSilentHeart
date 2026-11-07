extends Area3D

@export var next_scene: String = ""

var is_transitioning: bool = false


func interact():
	if is_transitioning:
		return

	if next_scene.is_empty():
		push_error("У двери не указана следующая сцена!")
		return

	is_transitioning = true

	var error = get_tree().change_scene_to_file(next_scene)

	if error != OK:
		push_error("Не удалось загрузить сцену: " + next_scene)
		is_transitioning = false
