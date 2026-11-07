extends CharacterBody3D

@export var walk_speed: float = 5.0
@export var run_speed: float = 8.0
@export var mouse_sensitivity: float = 0.002

@onready var head: Node3D = $Camera3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D
@onready var interaction_label: Label = $CanvasLayer/CenterContainer/Label

var current_door: Area3D = null
var gravity: float = 9.8
var camera_pitch: float = 0.0

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

    $CanvasLayer/CenterContainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    interaction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    interaction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    interaction_label.add_theme_font_size_override("font_size", 24)
    interaction_label.add_theme_color_override("font_color", Color.WHITE)
    interaction_label.visible = false

func _input(event):
    # Поворот камеры мышью
    if event is InputEventMouseMotion:
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            rotate_y(-event.relative.x * mouse_sensitivity)

            camera_pitch -= event.relative.y * mouse_sensitivity
            camera_pitch = clampf(camera_pitch, deg_to_rad(-89), deg_to_rad(89))
            head.rotation.x = camera_pitch

    # Выход из режима захвата мыши
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

    # Нажатие левой кнопки мыши
    if event is InputEventMouseButton:
      if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

        ray.force_raycast_update()

        if ray.is_colliding():
            var collider = ray.get_collider()

            if collider is Area3D and collider.has_method("interact"):
                print("КЛИК ПО ДВЕРИ!")
                collider.interact()
                return

        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
    # Гравитация
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = 0.0

    # WASD
    var input_dir = Vector2.ZERO

    if Input.is_key_pressed(KEY_W):
        input_dir.y -= 1
    if Input.is_key_pressed(KEY_S):
        input_dir.y += 1
    if Input.is_key_pressed(KEY_A):
        input_dir.x -= 1
    if Input.is_key_pressed(KEY_D):
        input_dir.x += 1

    input_dir = input_dir.normalized()

    var direction = (transform.basis * Vector3(
        input_dir.x, 0, input_dir.y
    )).normalized()

    # Бег
    var speed = walk_speed
    if Input.is_key_pressed(KEY_SHIFT):
        speed = run_speed

    # Движение
    if direction.length() > 0:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, walk_speed * 8 * delta)
        velocity.z = move_toward(velocity.z, 0, walk_speed * 8 * delta)

    move_and_slide()

func _process(_delta):
    ray.force_raycast_update()

    current_door = null

    if ray.is_colliding():
        var collider = ray.get_collider()

        if collider is Area3D and collider.has_method("interact"):
            current_door = collider
            interaction_label.visible = true
            interaction_label.text = "ДВЕРЬ\nНажмите ЛКМ, чтобы выйти"
            return

    interaction_label.visible = false
