extends Interactable

const BED_UI: PackedScene = preload(
	"res://scenes/ui/interactables/Bed.tscn"
)


func get_prompt_text() -> String:
	return "Кровать\nНажмите, чтобы отдохнуть"


func interact(_actor: Node) -> void:
	InterfaceManager.open_ui(BED_UI)
