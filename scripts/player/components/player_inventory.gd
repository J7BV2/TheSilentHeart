class_name PlayerInventory
extends Node

signal changed

const SLOT_COUNT := 3

var slots: Array[ItemData] = [null, null, null]

var unique_instance_ids: Array[StringName] = [
	&"", &"", &""
]

var selected_slot: int = 0


func has_free_slot() -> bool:
	for item in slots:
		if item == null:
			return true

	return false


func add_item(
	data: ItemData,
	unique_id: StringName = &""
) -> bool:

	if data == null:
		return false

	# Не допускаем повторного добавления
	# одного и того же уникального экземпляра.
	if unique_id != &"":
		for i in range(SLOT_COUNT):
			if unique_instance_ids[i] == unique_id:
				return false

	for i in range(SLOT_COUNT):
		if slots[i] == null:
			slots[i] = data
			unique_instance_ids[i] = unique_id

			changed.emit()
			return true

	return false


func select_slot(index: int) -> void:
	if index < 0 or index >= SLOT_COUNT:
		return

	selected_slot = index
	changed.emit()


func take_selected() -> Dictionary:
	var data := slots[selected_slot]

	if data == null:
		return {}

	var unique_id := unique_instance_ids[selected_slot]

	slots[selected_slot] = null
	unique_instance_ids[selected_slot] = &""

	changed.emit()

	return {
		"item_data": data,
		"unique_id": unique_id
	}


# Проверяет наличие предмета по его item_id.
func has_item(item_id: StringName) -> bool:

	for item in slots:

		if item != null and item.item_id == item_id:
			return true

	return false


# Заменяет один предмет другим в том же слоте.
func replace_one_item(
	old_item_id: StringName,
	new_data: ItemData
) -> bool:

	if new_data == null:
		return false

	for i in range(SLOT_COUNT):

		var item := slots[i]

		if item != null and item.item_id == old_item_id:

			slots[i] = new_data

			# Новый предмет уже не является старым
			# уникальным экземпляром.
			unique_instance_ids[i] = &""

			changed.emit()
			return true

	return false


# Удаляет указанные предметы из инвентаря.
# Все предметы удаляются одновременно.
func consume_items_by_id(
	item_ids: Array[StringName]
) -> bool:

	var slots_to_clear: Array[int] = []

	# Сначала проверяем наличие всех предметов.
	for item_id in item_ids:

		var found_index := -1

		for i in range(SLOT_COUNT):

			if slots_to_clear.has(i):
				continue

			var item := slots[i]

			if item != null and item.item_id == item_id:

				found_index = i
				break

		if found_index == -1:
			return false

		slots_to_clear.append(found_index)

	# Если все предметы найдены, удаляем их.
	for index in slots_to_clear:

		slots[index] = null
		unique_instance_ids[index] = &""

	changed.emit()

	return true
