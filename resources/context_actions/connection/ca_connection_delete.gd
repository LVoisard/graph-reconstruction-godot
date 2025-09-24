extends ConnectionContextAction

func perform_connection_context_action(_node: Connection) -> void:
	_node.graph.remove_connection(_node)
