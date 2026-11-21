class_name ItemData
extends Resource

@export var item_id: StringName
@export var display_name: String
@export_multiline var description: String

@export var icon: Texture2D
@export var model_scene: PackedScene

@export var world_scale: Vector3 = Vector3.ONE
@export var preview_scale: Vector3 = Vector3.ONE
@export var preview_offset: Vector3 = Vector3.ZERO

# Варианты появления уникального экземпляра предмета
@export var possible_spawn_ids: PackedStringArray = []
