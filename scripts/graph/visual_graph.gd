class_name VisualGraph extends Control

@onready var context_menu: ContextMenu = $"context_menu"

const graph_node_prefab: PackedScene = preload("res://scripts/graph_node/visual_graph_node.tscn")
const connection_prefab: PackedScene = preload("res://scripts/connection/connection.tscn")

var visual_nodes: Array[VisualGraphNode] = []
var visual_connections: Array[Connection] = []

var current_id: int = 0
var free_ids: Array[int] = []

var backend: GodotGraph = GodotGraph.new()

func _ready() -> void:
	print("ready")
	print(backend.GetGraphString())
	
func create_new_node() -> VisualGraphNode:
	var new_node = backend.CreateVertex()
	var visual: VisualGraphNode = graph_node_prefab.instantiate()
	visual.set_graph(self)
	visual.set_type(VisualGraphNode.NodeType.ANY)
	visual.set_id(new_node.Id)
	visual_nodes.append(visual)
	add_child(visual)
	print(backend.GetGraphString())
	return visual	
	
func create_new_connection(from: VisualGraphNode, to: VisualGraphNode) -> Connection:
	var con = backend.CreateEdge(backend.GetVertex(from.id), backend.GetVertex(to.id))
	var visual_con: Connection = connection_prefab.instantiate()
	visual_connections.append(visual_con)
	visual_con.set_connection_nodes(from, to)	
	visual_con.set_graph(self)
	add_child(visual_con)
	print(backend.GetGraphString())
	return visual_con

func remove_node_connections(node: VisualGraphNode) -> void:
	backend.RemoveVertexEdges(node.id)
	var to_remove: Array[Node] = []
	for con in visual_connections:
		if con.a() == node || con.b() == node:
			to_remove.append(con)
	for con in to_remove:
		visual_connections.erase(con)
		con.queue_free()
	print(backend.GetGraphString())

func remove_node(node: VisualGraphNode) -> void:
	remove_node_connections(node)
	backend.RemoveVertex(node.id)
	visual_nodes.erase(node)
	node.queue_free()
	print(backend.GetGraphString())
	
func change_node_type(node: VisualGraphNode, type: VisualGraphNode.NodeType) -> void:
	backend.GetVertex(node.id).SetType(type)
	node.set_type(type)
	node.update_visuals()
	print(backend.GetGraphString())
	
func change_connection_type(con: Connection, type: Connection.ConnectionType) -> void:
	backend.GetEdge(con.a().id, con.b().id).SetType(type)
	con.set_type(type)
	con.update_connection_visual()
	print(backend.GetGraphString())
	
		

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

func clear() -> void:
	backend.Clear()
	for con in visual_connections:
		con.queue_free()
	for node in visual_nodes:
		node.queue_free()
	visual_connections.clear()
	visual_nodes.clear()

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
