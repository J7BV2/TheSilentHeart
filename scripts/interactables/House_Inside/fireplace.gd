extends Interactable

const FIREPLACE_MELT_SCENE: PackedScene = preload(
	"res://scenes/ui/interactables/FireplaceMelt.tscn"
)

const FIREPLACE_ADD_SCENE: PackedScene = preload(
	"res://scenes/ui/interactables/FireplaceAdd.tscn"
)

@onready var fireplace_light: OmniLight3D = \
	get_node_or_null("../../Static/Fireplace/FireplaceLight")


func _ready() -> void:

	if not FireplaceState.state_changed.is_connected(
		_on_fireplace_state_changed
	):
		FireplaceState.state_changed.connect(
			_on_fireplace_state_changed
		)

	_on_fireplace_state_changed(
		FireplaceState.is_burning,
		FireplaceState.remaining_burn_minutes
	)


func _exit_tree() -> void:

	if FireplaceState.state_changed.is_connected(
		_on_fireplace_state_changed
	):
		FireplaceState.state_changed.disconnect(
			_on_fireplace_state_changed
		)


func get_prompt_text() -> String:
	return "Печь\n Нажмите, чтобы посмотреть"


func can_interact(actor: Node) -> bool:

	return actor != null and actor.get_node_or_null(
		"InventoryComponent"
	) is PlayerInventory


func interact(actor: Node) -> void:

	var inventory := actor.get_node_or_null(
		"InventoryComponent"
	) as PlayerInventory

	if inventory == null:
		return

	var scene: PackedScene

	if FireplaceState.is_burning:
		scene = FIREPLACE_ADD_SCENE
	else:
		scene = FIREPLACE_MELT_SCENE

	InterfaceManager.open_ui(scene, inventory)


func _on_fireplace_state_changed(
	burning: bool,
	_remaining_minutes: int
) -> void:

	if is_instance_valid(fireplace_light):
		fireplace_light.visible = burning
