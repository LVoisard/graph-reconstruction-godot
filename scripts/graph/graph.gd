class_name MyGraph extends Control


const graph_node_prefab: PackedScene = preload("res://scripts/graph_node/graph_node.tscn")
const connection_prefab: PackedScene = preload("res://scripts/connection/connection.tscn")

var nodes: Array[MyGraphNode] = []
var connections: Array[Connection] = []

var current_id: int = 0
var free_ids: Array[int] = []


func _ready() -> void:	
	child_entered_tree.connect(on_child_entered)
	child_exiting_tree.connect(on_child_exited)	
	
func on_child_entered(child: Node) -> void:
	if child is MyGraphNode:
		move_child(child, -1)
		nodes.append(child)
		assign_node_id(child)
	if child is Connection:
		move_child(child, 0)
		connections.append(child)

func on_child_exited(child: Node) -> void:
	print("deleted")
	if child is MyGraphNode:
		if child in nodes:
			nodes.remove_at(nodes.find(child))
			free_ids.append(child.id)
			free_ids.sort()
	if child is Connection:
		if child in connections:
			connections.remove_at(connections.find(child))
			
func assign_node_id(node: MyGraphNode) -> void:
	var new_id:int = -1
	if free_ids.is_empty():
		current_id += 1
		new_id = current_id
	else:
		new_id = free_ids.pop_front()
	node.set_id(new_id)


func get_graph_string() -> String:
	var s: String = "nodes\n"
	for node in nodes:
		s += "%d,%d,%d,%s\n" % [node.id, node.position.x, node.position.y, MyGraphNode.NodeType.keys()[node.node_type]]
	s += "edges\n"
	for con in connections:
		s += "%d,%d,%s\n" % [con.a().id, con.b().id, Connection.ConnectionType.keys()[con.connection_type]]	
	return s
	
func load_from_string(string_graph: Dictionary) -> void:
	print(string_graph)
	for node_string in string_graph["nodes"]:
		var params = (node_string as String).split(",")
		var new_node = graph_node_prefab.instantiate()
		add_child(new_node)		
		new_node.set_position(Vector2(int(params[1]), int(params[2])))
		new_node.set_type(MyGraphNode.NodeType.get(params[3]))
	for edge_string in string_graph["edges"]:
		var params = (edge_string as String).split(",")
		var new_con = connection_prefab.instantiate()
		add_child(new_con)
		new_con.set_connection_nodes(nodes[int(params[0]) - 1], nodes[int(params[1]) - 1])
		new_con.set_type(Connection.ConnectionType.get(params[2]))
	
func copy_graph(graph: MyGraph) -> void:
	var node_map = {}
	var con_map = {}
	for node in graph.nodes:
		node_map[node] = copy_node(node)	
	for con in graph.connections:
		var new_con = copy_con(con)
		new_con.set_connection_nodes(node_map[con.connection_nodes[0]], node_map[con.connection_nodes[1]])		
			
	print("copy")

func copy_node(node: MyGraphNode) -> MyGraphNode:
	var new_node = graph_node_prefab.instantiate() as MyGraphNode
	add_child(new_node)
	new_node.copy_node(node)
	return new_node
	
func copy_con(con: Connection) -> Connection:
	var new_con = connection_prefab.instantiate() as Connection
	add_child(new_con)
	new_con.copy_connector(con)
	return new_con
	
func clear() -> void:
	for node in nodes:
		node.queue_free()
	print("clearing graph")
