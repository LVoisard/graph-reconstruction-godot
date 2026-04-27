@tool
class_name VisualGraph extends Control

@onready var context_menu: ContextMenu = $"context_menu"

const graph_node_prefab: PackedScene = preload("res://scripts/graph_node/visual_graph_node.tscn")
const connection_prefab: PackedScene = preload("res://scripts/connection/connection.tscn")

var visual_nodes: Array[VisualGraphNode] = []
var visual_connections: Array[Connection] = []

var current_id: int = 0
var free_ids: Array[int] = []

var _drag_offsets: Dictionary = {}   # node -> Vector2
var _is_panning: bool = false
var _pan_start_mouse: Vector2
var _pan_start_positions: Dictionary = {}  # node -> Vector2

var backend: LVGraph = LVGraph.new()
	
func create_new_node() -> VisualGraphNode:
	var new_node = backend.create_node()
	var visual: VisualGraphNode = graph_node_prefab.instantiate()
	visual.set_graph(self)
	visual.set_type(VisualGraphNode.NodeType.ANY)
	visual.set_id(new_node.get_id())
	register_node(visual)
	visual_nodes.append(visual)
	add_child(visual)
	return visual	
	
func create_new_connection(from: VisualGraphNode, to: VisualGraphNode) -> Connection:
	backend.connect_nodes(from.id, to.id)
	var visual_con: Connection = connection_prefab.instantiate()
	visual_connections.append(visual_con)
	visual_con.set_connection_nodes(from, to)	
	visual_con.set_graph(self)
	add_child(visual_con)
	return visual_con

func remove_node_connections(node: VisualGraphNode) -> void:
	backend.RemoveVertexEdges(node.get_id())
	var to_remove: Array[Node] = []
	for con in visual_connections:
		if con.a() == node || con.b() == node:
			to_remove.append(con)
	for con in to_remove:
		visual_connections.erase(con)
		con.queue_free()

func remove_node(node: VisualGraphNode) -> void:
	remove_node_connections(node)
	unregister_node(node)
	backend.remove_node(node.id)
	visual_nodes.erase(node)
	node.queue_free()
	
func remove_connection(con: Connection) -> void:
	backend.RemoveEdge(con.a().id, con.b().id)
	visual_connections.erase(con)
	con.queue_free()
	
func change_node_type(node: VisualGraphNode, type: VisualGraphNode.NodeType) -> void:
	backend.get_node(node.id).set_metadata("type", type)
	node.set_type(type)
	node.update_visuals()
	
func update_node_position(node: VisualGraphNode) ->void:
	backend.get_node(node.id).set_metadata("position", node.position)
	
	
func change_connection_type(con: Connection, type: Connection.ConnectionType) -> void:
	backend.GetEdge(con.a().id, con.b().id).SetType(type)
	con.set_type(type)
	con.update_connection_visual()
	
func create_visuals_from_backend() -> void:
	clear_visuals()
	for v in backend.get_nodes().values():
		var visual = graph_node_prefab.instantiate() as VisualGraphNode
		visual.set_graph(self)
		visual.set_type(v.get_metadata("type"))
		visual.set_id(v.get_id())
		visual.position = v.get_metadata("position")
		visual_nodes.append(visual)
		add_child(visual)
	for e in backend.get_edges():
		var visual_con: Connection = connection_prefab.instantiate()
		visual_connections.append(visual_con)
		visual_con.set_connection_nodes(visual_nodes[visual_nodes.find_custom(func(x): return x.get_id() == e.from)], visual_nodes[visual_nodes.find_custom(func(x): return x.get_id() == e.to)])	
		visual_con.set_type(e.type)
		visual_con.set_graph(self)
		
		add_child(visual_con)
		
func update_visuals_from_backend() -> void:
	for v in backend.GetVertices():
		var index = visual_nodes.find_custom(func(x): return x.id == v.Id)
		if index == -1:
			#print(v)
			continue
		var visual: VisualGraphNode = visual_nodes[index]
		visual.position = Vector2(v.X, v.Y)
		visual.update_visuals()
	for e in backend.GetEdges():
		var index = visual_connections.find_custom(func(x): return x.a().id == e.From.Id and x.b().id == e.To.Id)
		if index == -1:
			#print(e)
			continue
		var visual_con: Connection = visual_connections[index]
		visual_con.update_connection_position()
		move_child(visual_con, -1)

func clear_all() -> void:
	clear_backend()
	clear_visuals()
	
func clear_backend() -> void:
	pass
	
func copy_graph(input: VisualGraph) -> void:
	var mapping: Dictionary[VisualGraphNode, VisualGraphNode] = {}
	for n in input.visual_nodes:
		mapping[n] = create_new_node() as VisualGraphNode
		change_node_type(mapping[n],n.type)
		mapping[n].position = n.position 
		update_node_position(mapping[n])
	for c in input.visual_connections:
		var con = create_new_connection(mapping[c.a()], mapping[c.b()])
		change_connection_type(con, c.connection_type)
	
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
	
# call this when you spawn a graph node
func register_node(node: Control) -> void:
	var draggable = node.find_child("Draggable")
	if not draggable:
		return
	draggable.drag_started.connect(_on_drag_started)
	draggable.drag_moved.connect(_on_drag_moved)
	draggable.drag_ended.connect(_on_drag_ended)

func unregister_node(node: Control) -> void:
	var draggable = node.find_child("Draggable")
	if not draggable:
		return
	draggable.drag_started.disconnect(_on_drag_started)
	draggable.drag_moved.disconnect(_on_drag_moved)
	draggable.drag_ended.disconnect(_on_drag_ended)
	
func _on_drag_started(node: Control, global_mouse: Vector2) -> void:
	_drag_offsets[node] = global_mouse - node.global_position

func _on_drag_moved(node: Control, global_mouse: Vector2) -> void:
	if not _drag_offsets.has(node):
		return
		
	var target = global_mouse - _drag_offsets[node]
	print("hello")
	node.position = _clamped(node, target)

func _on_drag_ended(node: Control) -> void:
	_drag_offsets.erase(node)

# --- canvas pan ---

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var rect = Rect2(global_position, size)
		if event.pressed and rect.has_point(event.global_position):
			_is_panning = true
			_pan_start_mouse = event.global_position
			for child in get_children():
				if child is Control:
					_pan_start_positions[child] = child.position
		else:
			_is_panning = false
			_pan_start_positions.clear()

	if event is InputEventMouseMotion and _is_panning:
		var delta = event.global_position - _pan_start_mouse
		for node in _pan_start_positions:
			node.position = _clamped(node, _pan_start_positions[node] + delta)
		get_viewport().set_input_as_handled()

# --- bounds ---

func _clamped(node: Control, pos: Vector2) -> Vector2:
	return Vector2(
		clamp(pos.x, 0.0, size.x - node.size.x),
		clamp(pos.y, 0.0, size.y - node.size.y)
	)
