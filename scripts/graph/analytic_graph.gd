class_name AnalyticGraph

var nodes: Dictionary = {} # id: Node
var edges: Array[AnalyticGraphEdge] = []

func _init(dict: Dictionary):
	for node in dict["nodes"]:
		var params = node.split(",")
		nodes[int(params[0])] = AnalyticGraphNode.new(int(params[0]), int(params[1]), int(params[2]), params[3], params[4])
	for edge in dict["edges"]:
		var params = edge.split(",")
		edges.append(AnalyticGraphEdge.new(int(params[0]), int(params[1]), params[2]))

func add_node(node: AnalyticGraphNode):
	nodes[node.id] = node

func add_edge(edge: AnalyticGraphEdge):
	edges.append(edge)
	
func get_next_id() -> int:
	var ids = []
	for i in nodes.keys().max():
		ids.append(i + 1)
		
	if ids.size() == nodes.keys().max():
		return ids.size() + 1
	
	for node_id in nodes:
		if node_id in ids:
			ids.remove_at(node_id - 1)
			break
	
	return ids.pop_front()
	
func to_dict() -> Dictionary:
	var d = {"nodes": [], "edges": []}
	for node in nodes.values():
		d["nodes"].append("%d,%d,%d,%s" % [node.id, node.x, node.y, node.label])
	for edge in edges:
		d["edges"].append("%d,%d,%s" % [edge.source, edge.target, edge.label])
	return d

class AnalyticGraphNode:
	var id: int
	var x: int
	var y: int
	var label: String
	var annotation: String

	func _init(_id, _x, _y, _label, _annotation):
		id = _id
		x = _x
		y = _y
		label = _label
		annotation = _annotation
	
class AnalyticGraphEdge:
	var source: int
	var target: int
	var label: String

	func _init(_source, _target, _label):
		source = _source
		target = _target
		label = _label
