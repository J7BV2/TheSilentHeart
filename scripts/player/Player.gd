extends CharacterBody3D

@onready var movement_controller: PlayerMovementController = $MovementController
@onready var interactor: PlayerInteractor = $Interactor

const ITEM_PICKUP_SCENE: PackedScene = preload(
	"res://scenes/items/ItemPickup.tscn"
)

@onready var inventory: PlayerInventory = $InventoryComponent
@onready var inventory_hud: InventoryHUD = $CanvasLayer/Inventory

func _ready() -> void:

	inventory_hud.setup(inventory)

	inventory_hud.drop_requested.connect(
		_drop_selected_item
	)

	if not DisplayServer.is_touchscreen_available():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	movement_controller.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:

	# Освободить мышь
	if event.is_action_pressed(&"ui_cancel"):

		if is_instance_valid(InterfaceManager.current_ui):
			return

		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_viewport().set_input_as_handled()
		return

	# Взаимодействие
	if event.is_action_pressed(&"interact"):

		if interactor.try_interact(self):
			get_viewport().set_input_as_handled()

	if is_instance_valid(InterfaceManager.current_ui):
		return

	# Выбор слота
	if event.is_action_pressed(&"inventory_slot_1"):
		inventory.select_slot(0)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed(&"inventory_slot_2"):
		inventory.select_slot(1)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed(&"inventory_slot_3"):
		inventory.select_slot(2)
		get_viewport().set_input_as_handled()
		return

	# Выброс предмета
	if event.is_action_pressed(&"drop_item"):
		_drop_selected_item()
		get_viewport().set_input_as_handled()
		return

	# Взаимодействие
	if event.is_action_pressed(&"interact"):

		if interactor.try_interact(self):
			get_viewport().set_input_as_handled()

		elif not DisplayServer.is_touchscreen_available():
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _drop_selected_item() -> void:

	var item_info := inventory.take_selected()

	if item_info.is_empty():
		return

	var data := item_info["item_data"] as ItemData
	var unique_id := StringName(item_info["unique_id"])

	var session := get_tree().get_first_node_in_group(
		"game_session"
	) as GameSession

	if session == null or session.current_level == null:
		inventory.add_item(data, unique_id)
		return

	# Уникальный предмет снова становится доступен в мире.
	ItemRegistry.mark_dropped(unique_id)

	var pickup := ITEM_PICKUP_SCENE.instantiate() as WorldItemPickup

	pickup.item_data = data
	pickup.unique_instance_id = unique_id

	session.current_level.add_child(pickup)

	var forward := -global_transform.basis.z

	pickup.global_position = (
		global_position
		+ forward * 1.2
		+ Vector3.UP * 0.4
	)

	pickup.rotation.y = rotation.y
