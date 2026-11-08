extends Node

@onready var level_container = $LevelContainer

var current_level: Node

const OUTSIDE_SCENE = preload("res://Scenes/game/levels/Game_Outside.tscn")
const HOUSE_SCENE = preload("res://Scenes/game/levels/Game_House.tscn")


func _ready() -> void:
	change_level(OUTSIDE_SCENE)


func change_level(scene: PackedScene) -> void:
	if current_level:
		current_level.queue_free()

	current_level = scene.instantiate()
	level_container.add_child(current_level)


func go_to_outside() -> void:
	change_level(OUTSIDE_SCENE)


func go_to_house() -> void:
	change_level(HOUSE_SCENE)
