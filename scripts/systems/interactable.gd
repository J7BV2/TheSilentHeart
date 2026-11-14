class_name Interactable
extends Area3D

@export_multiline var prompt_text: String = "Нажмите, чтобы взаимодействовать"


# Можно ли сейчас взаимодействовать с объектом
func can_interact(_actor: Node) -> bool:
	return true


# Получение текста подсказки
func get_prompt_text() -> String:
	return prompt_text


# Основное взаимодействие
func interact(_actor: Node) -> void:
	pass
