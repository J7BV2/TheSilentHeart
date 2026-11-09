class_name Interactable
extends Area3D

@export_multiline var prompt_text: String = "ЛКМ — Взаимодействовать"


func get_prompt_text() -> String:
	return prompt_text


func interact(_actor: Node) -> void:
	pass
