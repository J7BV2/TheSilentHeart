extends Interactable

const CHOPPING_LOG_UI: PackedScene = preload(
	"res://scenes/ui/interactables/ChoppingLog.tscn"
)


func get_prompt_text() -> String:
	return "Колода\nНажмите, чтобы рубить"


func can_interact(actor: Node) -> bool:

	if actor == null:
		return false

	return actor.get_node_or_null(
		"InventoryComponent"
	) is PlayerInventory


func interact(actor: Node) -> void:

	var inventory := actor.get_node_or_null(
		"InventoryComponent"
	) as PlayerInventory

	if inventory == null:
		return

	# Открываем окно рубки и передаём ему инвентарь.
	InterfaceManager.open_ui(
		CHOPPING_LOG_UI,
		inventory
	)
