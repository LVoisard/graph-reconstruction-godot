extends GraphContextAction

func perform_graph_context_action(graph: VisualGraph) -> void:
	print("creating new node")
	
	var visual = graph.create_new_node()
	visual.position = graph.get_global_mouse_position() - visual.get_rect().size / 2
	
