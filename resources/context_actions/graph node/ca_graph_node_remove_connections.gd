extends ContextAction


func perform_context_action(_node: Node) -> void:
	(_node as VisualGraphNode).remove_all_connections()
	
