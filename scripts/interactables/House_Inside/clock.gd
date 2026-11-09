extends Area3D


func get_prompt_text() -> String:

	var time_manager := get_tree().get_first_node_in_group(
		"time_manager"
	) as TimeManager

	if time_manager == null:
		return "ЧАСЫ\nВремя недоступно"

	return "ЧАСЫ\n" + time_manager.get_time_string()
