extends ContextAction

func perform_context_action(node: Node) -> void:
	node.queue_free()
