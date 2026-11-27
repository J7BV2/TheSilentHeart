extends CharacterBody3D

@onready var movement_controller: PlayerMovementController = $MovementController
@onready var interactor: PlayerInteractor = $Interactor

const ITEM_PICKUP_SCENE: PackedScene = preload(
	"res://scenes/items/ItemPickup.tscn"
)

@onready var inventory: PlayerInventory = $InventoryComponent
@onready var inventory_hud: InventoryHUD = $CanvasLayer/Inventory
@onready var item_dropper: ItemDropper = $ItemDropper

@onready var health_component: PlayerHealth = $HealthComponent
@onready var health_points: Control = $CanvasLayer/HealthPoints

func _ready() -> void:

	inventory_hud.setup(inventory)
	
	health_points.setup(health_component)

	inventory_hud.drop_requested.connect(
		item_dropper.drop_selected_item
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
		item_dropper.drop_selected_item()
		get_viewport().set_input_as_handled()
		return

	# Взаимодействие
	if event.is_action_pressed(&"interact"):

		if interactor.try_interact(self):
			get_viewport().set_input_as_handled()

		elif not DisplayServer.is_touchscreen_available():
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
