class_name VisualGraph extends Control

const graph_node_prefab: PackedScene = preload("res://scripts/graph_node/rule/rule_graph_node.tscn")
const connection_prefab: PackedScene = preload("res://scripts/connection/connection.tscn")

var visual_nodes: Dictionary[int, VisualGraphNode] = {}
var visual_connections: Dictionary[int, Connection] = {}

var current_id: int = 0
var free_ids: Array[int] = []

var backend: GodotGraph = GodotGraph.new()

func _ready() -> void:
	print("ready")
	var v1 = backend.CreateVertex()
	var v2 = backend.CreateVertex()
	
	var edge = backend.CreateEdge(v1, v2)
	#node.SetPosition(100, 100)
	print(backend.GetGraphString())
	
			
func add_node(node: VisualGraphNode) -> void:
	var new_node = backend.CreateVertex()
	
	visual_nodes.set(new_node.Id, node)
	add_child(node)
	node.set_type(VisualGraphNode.NodeType.ANY)
	node.set_id(new_node.Id)
	node.change_visuals()
	
				
func assign_node_id(node: VisualGraphNode) -> void:
	var new_id:int = -1
	if free_ids.is_empty():
		current_id = visual_nodes.size()
		new_id = current_id
	else:
		new_id = free_ids.pop_front()
	#node.set_id(new_id)
	
func load_from_string(string_graph: Dictionary) -> void:
	print(string_graph)
	for node_string in string_graph["visual_nodes"]:
		var params = (node_string as String).split(",")
		var new_node = graph_node_prefab.instantiate()
		add_child(new_node)		
		new_node.set_position(Vector2(int(params[1]), int(params[2])))
		new_node.set_type(VisualGraphNode.NodeType.get(params[3]))
	for edge_string in string_graph["edges"]:
		var params = (edge_string as String).split(",")
		var new_con = connection_prefab.instantiate()
		add_child(new_con)
		new_con.set_connection_nodes(visual_nodes[int(params[0]) - 1], visual_nodes[int(params[1]) - 1])
		new_con.set_type(Connection.ConnectionType.get(params[2]))
		visual_nodes[int(params[0]) - 1].add_connection(new_con)
		visual_nodes[int(params[1]) - 1].add_connection(new_con)

func load_from_analytic(graph: AnalyticGraph) -> void:
	var id_dict = {}
	for node in graph.visual_nodes.values():
		var new_node = graph_node_prefab.instantiate()
		id_dict[node.id] = new_node
		add_child(new_node)
		new_node.set_position(Vector2(node.x, node.y))
		new_node.set_type(VisualGraphNode.NodeType.get(node.label))
	for edge in graph.edges:
		var new_con = connection_prefab.instantiate()
		add_child(new_con)
		new_con.set_connection_nodes(id_dict[edge.source], id_dict[edge.target])
		new_con.set_type(Connection.ConnectionType.get(edge.label))
		id_dict[edge.source].add_connection(new_con)
		id_dict[edge.target].add_connection(new_con)

		

func copy_node(node: RuleGraphNode) -> RuleGraphNode:
	var new_node = graph_node_prefab.instantiate() as RuleGraphNode
	add_child(new_node)
	new_node.copy_node(node)
	return new_node
	
func copy_con(con: Connection) -> Connection:
	var new_con = connection_prefab.instantiate() as Connection
	add_child(new_con)
	new_con.copy_connector(con)
	return new_con


func get_neighbours(node: RuleGraphNode) -> Array[RuleGraphNode]:
	var neighbours: Array[RuleGraphNode] = []
	for con in node.connections:
		if con.connection_type == Connection.ConnectionType.Relational: continue
		if node == con.a():
			neighbours.append(con.get_other(node))
	return neighbours

func get_lock_keys(node: RuleGraphNode) -> Array[RuleGraphNode]:
	var neighbours: Array[RuleGraphNode] = []
	for con in node.connections:
		if con.connection_type == Connection.ConnectionType.Directional: continue
		neighbours.append(con.get_other(node))
	return neighbours
