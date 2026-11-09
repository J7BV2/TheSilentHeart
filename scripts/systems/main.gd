extends Node

const MAIN_MENU: PackedScene = preload(
	"res://scenes/main/Main_Menu.tscn"
)

const GAME_SESSION: PackedScene = preload(
	"res://scenes/game/Game_Session.tscn"
)

@onready var scene_container: Node = $SceneContainer


func _ready() -> void:
	show_main_menu()


func _show_scene(scene: PackedScene) -> void:
	for child in scene_container.get_children():
		scene_container.remove_child(child)
		child.queue_free()

	scene_container.add_child(scene.instantiate())


func show_main_menu() -> void:
	_show_scene(MAIN_MENU)


func start_game() -> void:
	_show_scene(GAME_SESSION)
