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
	
func update_node_position(node: VisualGraphNode) ->void:
	backend.GetVertex(node.id).SetPosition(node.position.x, node.position.y)
	
	
func change_connection_type(con: Connection, type: Connection.ConnectionType) -> void:
	backend.GetEdge(con.a().id, con.b().id).SetType(type)
	con.set_type(type)
	con.update_connection_visual()
	print(backend.GetGraphString())	
	
func create_visuals_from_backend() -> void:
	clear_visuals()
	for v in backend.GetVertices():
		var visual = graph_node_prefab.instantiate() as VisualGraphNode
		visual.set_graph(self)
		visual.set_type(v.Type)
		visual.set_id(v.Id)
		visual.position = Vector2(v.X, v.Y)
		visual_nodes.append(visual)
		add_child(visual)
	for e in backend.GetEdges():
		var visual_con: Connection = connection_prefab.instantiate()
		visual_connections.append(visual_con)
		visual_con.set_connection_nodes(visual_nodes[visual_nodes.find_custom(func(x): return x.id == e.From.Id)], visual_nodes[visual_nodes.find_custom(func(x): return x.id == e.To.Id)])	
		visual_con.set_type(e.Type)
		visual_con.set_graph(self)
		
		add_child(visual_con)

func clear_all() -> void:
	clear_backend()
	clear_visuals()
	
func clear_backend() -> void:
	backend.Clear()	
	
func clear_visuals() -> void:
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
