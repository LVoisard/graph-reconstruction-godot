extends ContextAction


func perform_context_action(_node: Node) -> void:
	(_node as MyGraphNode).remove_all_connections()
	
