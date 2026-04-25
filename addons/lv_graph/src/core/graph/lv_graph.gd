class_name LVGraph
extends Resource

var _next_id: int = -1

var _nodes: Dictionary[int, LVNode]
var _edges: Array[LVEdge]

func create_node() -> LVNode:
	var node = LVNode.new(_next_node_id())
	_nodes[node.get_id()] = node
	return node
	
func remove_node(id: int) -> void:
	_nodes.erase(id)

func connect_nodes(n1: int, n2: int) -> void:
	var edge = LVEdge.new()
	edge.from = n1
	edge.to = n2
	_edges.push_back(edge)
	
func get_next_node_id(id: int) -> int:
	var ids = _nodes.keys()
	var i = 0
	while id >= ids[i] and i < _nodes.size():
		i += 1
	print(ids[i])
	return ids[i]

func get_node(id: int) -> LVNode:
	return _nodes[id]
	
func get_nodes() -> Dictionary[int, LVNode]:
	return _nodes
	
func get_edges() -> Array[LVEdge]:
	return _edges


func _next_node_id() -> int:
	_next_id += 1
	return _next_id
	
	
static func from_string(graph_string: String) -> LVGraph:
	var graph = LVGraph.new()
	
	var node = graph.create_node()
	node.set_metadata("type", 0)
	node.set_metadata("position", Vector2(10, 10))
	
	return graph
