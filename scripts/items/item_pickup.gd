class_name WorldItemPickup
extends Interactable

const INSPECTION_SCENE: PackedScene = preload(
	"res://scenes/ui/items/ItemInspection.tscn"
)

@export var item_data: ItemData
@export var unique_instance_id: StringName = &""

@onready var visual_root: Node3D = $VisualRoot


func _ready() -> void:
	if item_data == null:
		return

	if item_data.model_scene == null:
		return

	var model := item_data.model_scene.instantiate() as Node3D

	if model == null:
		return

	visual_root.add_child(model)
	model.scale = item_data.world_scale


func get_prompt_text() -> String:
	if item_data == null:
		return "Предмет"

	return "Подобрать: " + item_data.display_name + "\nЛКМ"


func can_interact(actor: Node) -> bool:
	if item_data == null:
		return false

	if ItemRegistry.is_collected(unique_instance_id):
		return false

	var inventory := actor.get_node_or_null(
		"InventoryComponent"
	) as PlayerInventory

	return inventory != null and inventory.has_free_slot()


func interact(actor: Node) -> void:
	var inventory := actor.get_node_or_null(
		"InventoryComponent"
	) as PlayerInventory

	if inventory == null:
		return

	if not inventory.add_item(item_data, unique_instance_id):
		return

	ItemRegistry.mark_collected(unique_instance_id)

	queue_free()

	InterfaceManager.open_ui(INSPECTION_SCENE, item_data)
