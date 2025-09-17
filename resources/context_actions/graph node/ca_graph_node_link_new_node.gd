extends GraphNodeContextAction

func perform_graph_node_context_action(graph_node: VisualGraphNode) -> void:
	print("linking to new node")
	var graph: VisualGraph = graph_node.graph
	var new_graph_node = graph.create_new_node()	
	new_graph_node.set_global_position(graph_node.get_position() + Vector2(150, 0))
	
	var con = graph.create_new_connection(graph_node, new_graph_node)
