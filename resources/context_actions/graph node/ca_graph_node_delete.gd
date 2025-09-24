extends GraphNodeContextAction

func perform_graph_node_context_action(_node: VisualGraphNode) -> void:
	_node.graph.remove_node(_node)
