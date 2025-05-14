extends ContextAction

var connection_prefab: PackedScene = null
var waiting: bool = false

func perform_context_action(node: Node) -> void:
	if connection_prefab == null:
		connection_prefab = load("res://scripts/connection/connection.tscn")
	wait_for_click(node as MyGraphNode)
	
func wait_for_click(starting_node: MyGraphNode) -> void:
	waiting = true	
	while waiting:
		process_input(starting_node)
		await starting_node.get_tree().create_timer(starting_node.get_process_delta_time()).timeout	
	
	
func process_input(starting_node: MyGraphNode) -> void:
	if Input.is_action_pressed("left_click"):
		var mouse_pos = starting_node.get_global_mouse_position()
		var graph_nodes = starting_node.get_tree().get_nodes_in_group("graph_nodes")
		for node in graph_nodes:
			if node == starting_node: continue
			if starting_node.get_parent() != node.get_parent(): continue
			if (node as MyGraphNode).get_global_rect().has_point(mouse_pos):
				var c = connection_prefab.instantiate() as Connection
				c.set_connection_nodes(starting_node, node as MyGraphNode)
				node.add_sibling(c)
				starting_node.add_connection(c)
				node.add_connection(c)
				waiting = false
				return
		waiting = false
