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
