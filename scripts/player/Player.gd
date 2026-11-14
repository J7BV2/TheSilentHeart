extends CharacterBody3D

@onready var movement_controller: PlayerMovementController = $MovementController
@onready var interactor: PlayerInteractor = $Interactor


func _ready() -> void:
	if not DisplayServer.is_touchscreen_available():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	movement_controller.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:

	# Освободить мышь
	if event.is_action_pressed(&"ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_viewport().set_input_as_handled()
		return

	# Взаимодействие
	if event.is_action_pressed(&"interact"):

		if interactor.try_interact(self):
			get_viewport().set_input_as_handled()

		# При нажатии в пустоту вернуть захват мыши
		elif not DisplayServer.is_touchscreen_available():
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
