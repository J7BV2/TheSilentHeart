extends Node

const MAIN_MENU: PackedScene = preload("res://scenes/main/Main_Menu.tscn")

@onready var scene_container: Node = $SceneContainer


func _ready() -> void:
	show_main_menu()


func show_main_menu() -> void:
	var menu := MAIN_MENU.instantiate()
	scene_container.add_child(menu)
