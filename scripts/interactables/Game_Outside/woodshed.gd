extends Interactable

const ITEM_INSPECTION_SCENE: PackedScene = preload(
	"res://scenes/ui/items/ItemInspection.tscn"
)	

const TOTAL_LOGS: int = 27

# Ресурс полена.
@export var log_data: ItemData

# Уникальный ID этой поленницы.
@export var source_id: StringName = &"outside_woodshed"

# 0 = Log1 -> Log27
# 1 = Log27 -> Log1
@export_enum(
	"Log1 -> Log27",
	"Log27 -> Log1"
)
var removal_order: int = 1

# Визуальные модели поленьев внутри Woodshed.glb.
@onready var logs_root: Node3D = get_node_or_null(
	"../../World/Woodshed/Woodshed"
) as Node3D


func _ready() -> void:

	if log_data == null:
		push_error("[Woodshed] Не назначен log_data!")
		return

	if logs_root == null:
		push_error("[Woodshed] Не найдены модели поленьев!")
		return

	# Восстанавливаем состояние поленницы.
	_refresh_logs()


# Подсказка игроку.
func get_prompt_text() -> String:

	var taken_count := ItemRegistry.get_harvested_count(
		source_id
	)

	var remaining := TOTAL_LOGS - taken_count

	if remaining <= 0:
		return "Поленья закончились"

	return "Поленница\nЛКМ - взять полено (" + str(remaining) + ")"


# Проверяем, можно ли взять полено.
func can_interact(actor: Node) -> bool:

	if log_data == null or logs_root == null:
		return false

	var taken_count := ItemRegistry.get_harvested_count(
		source_id
	)

	if taken_count >= TOTAL_LOGS:
		return false

	var inventory := actor.get_node_or_null(
		"InventoryComponent"
	) as PlayerInventory

	if inventory == null:
		return false

	return inventory.has_free_slot()


# Получаем следующий номер полена.
func _get_next_log_number(taken_count: int) -> int:

	if removal_order == 0:
		return taken_count + 1

	return TOTAL_LOGS - taken_count


# Взаимодействие с поленницей.
func interact(actor: Node) -> void:

	if not can_interact(actor):
		return

	var inventory := actor.get_node_or_null(
		"InventoryComponent"
	) as PlayerInventory

	if inventory == null:
		return

	var taken_count := ItemRegistry.get_harvested_count(
		source_id
	)

	var log_number := _get_next_log_number(
		taken_count
	)

	# У каждого полена собственный уникальный ID.
	var unique_id := StringName(
		"%s_log_%02d" % [String(source_id), log_number]
	)

	# Сначала пытаемся добавить полено в инвентарь.
	if not inventory.add_item(log_data, unique_id):
		return

	# Помечаем уникальный экземпляр как подобранный.
	ItemRegistry.mark_collected(unique_id)

	# Увеличиваем количество взятых поленьев.
	ItemRegistry.set_harvested_count(
		source_id,
		taken_count + 1
	)

	# Обновляем внешний вид поленницы.
	_refresh_logs()

	# Открываем существующий экран осмотра предмета.
	InterfaceManager.open_ui(
		ITEM_INSPECTION_SCENE,
		log_data
	)

	print(
		"[Woodshed] Взято полено №",
		log_number,
		". Осталось: ",
		TOTAL_LOGS - taken_count - 1
	)


# Восстанавливаем видимость всех 27 поленьев.
func _refresh_logs() -> void:

	if logs_root == null:
		return

	var taken_count := clampi(
		ItemRegistry.get_harvested_count(source_id),
		0,
		TOTAL_LOGS
	)

	for log_number in range(1, TOTAL_LOGS + 1):

		var log_node := logs_root.get_node_or_null(
			"Log" + str(log_number)
		) as VisualInstance3D

		if log_node == null:
			push_warning(
				"[Woodshed] Не найден Log" + str(log_number)
			)
			continue

		var should_be_visible: bool

		if removal_order == 0:
			# Убираем Log1, Log2 ... Log27.
			should_be_visible = log_number > taken_count

		else:
			# Убираем Log27, Log26 ... Log1.
			should_be_visible = (
				log_number <= TOTAL_LOGS - taken_count
			)

		log_node.visible = should_be_visible
