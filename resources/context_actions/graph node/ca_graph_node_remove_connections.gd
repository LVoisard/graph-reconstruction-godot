extends GraphNodeContextAction


func perform_graph_node_context_action(node: VisualGraphNode) -> void:
	node.graph.remove_node_connections(node)
	
