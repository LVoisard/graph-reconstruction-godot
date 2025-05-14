class_name SubContextAction extends ContextAction

@export var sub_context_actions: Array[ContextAction] = []

func on_sub_context_action_clicked(id: int,_node: Node) -> void:
	sub_context_actions[id].perform_context_action(_node)
