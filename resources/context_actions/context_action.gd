class_name ContextAction

extends Resource

@export var action_text = ""

func get_action_name() -> String:
	return action_text

func perform_context_action(_node: Node) -> void:
	print("performing action")
