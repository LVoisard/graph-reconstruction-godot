extends GraphNodeContextAction

var waiting: bool = false
func perform_graph_node_context_action(node: VisualGraphNode) -> void:
	print("linking to existing node")
	wait_for_click(node)
	
func wait_for_click(starting_node: VisualGraphNode) -> void:
	waiting = true	
	while waiting:
		process_input(starting_node)
		await starting_node.get_tree().physics_frame
	
	
func process_input(starting_node: VisualGraphNode) -> void:
	if Input.is_action_pressed("left_click"):
		var mouse_pos = starting_node.get_global_mouse_position()
		var graph_nodes = starting_node.get_tree().get_nodes_in_group("graph_nodes")
		for node in graph_nodes:
			if node == starting_node: continue
			if starting_node.get_parent() != node.get_parent(): continue
			if (node as VisualGraphNode).get_global_rect().has_point(mouse_pos):
				var con = starting_node.graph.create_new_connection(starting_node, node)
				waiting = false
				return
		print("cancelled")
		waiting = false
