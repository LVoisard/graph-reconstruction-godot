class_name VisualGraph extends Control

const graph_node_prefab: PackedScene = preload("res://scripts/graph_node/rule/rule_graph_node.tscn")
const connection_prefab: PackedScene = preload("res://scripts/connection/connection.tscn")

var visual_nodes: Dictionary[int, VisualGraphNode] = {}
var visual_connections: Dictionary[int, Connection] = {}

var current_id: int = 0
var free_ids: Array[int] = []

var backend = preload("res://scripts/graph-lib/Graph.cs").new()
var node_backend = preload("res://scripts/graph-lib/Node.cs")

func _ready() -> void:
	print("ready")
	
func _process(delta: float) -> void:
	if visual_nodes.is_empty(): return
	if Input.is_key_pressed(KEY_O):
		await apply_force_layout()
	if Input.is_key_pressed(KEY_V):
		if is_traversable():
			print("Graph is valid")
			
func add_node(node: VisualGraphNode) -> void:
	var new_node = node_backend.new();
	new_node.init(node.type)
	backend.AddNode(new_node)
	visual_nodes.set(new_node.id, node)
	
	
func on_child_entered(child: Node) -> void:
	if child is RuleGraphNode:
		move_child(child, -1)
		visual_nodes.append(child)
		assign_node_id(child)
	if child is Connection:
		move_child(child, 0)
		connections.append(child)

func on_child_exited(child: Node) -> void:
	if child is RuleGraphNode:
		if child in visual_nodes:
			visual_nodes.remove_at(visual_nodes.find(child))
			free_ids.append(child.id)
			free_ids.sort()
	if child is Connection:
		if child in connections:
			connections.remove_at(connections.find(child))
			
func assign_node_id(node: VisualGraphNode) -> void:
	var new_id:int = -1
	if free_ids.is_empty():
		current_id = visual_nodes.size()
		new_id = current_id
	else:
		new_id = free_ids.pop_front()
	#node.set_id(new_id)


func get_graph_string() -> String:
	var s: String = "visual_nodes\n"
	for node in visual_nodes:
		s += "%d,%d,%d,%s,%s\n" % [node.id, node.position.x, node.position.y, VisualGraphNode.NodeType.keys()[node.node_type], RuleGraphNode.Annotation.keys()[node.annotation]]
	s += "edges\n"
	for con in connections:
		s += "%d,%d,%s\n" % [con.a().id, con.b().id, Connection.ConnectionType.keys()[con.connection_type]]	
	return s
	
func get_graph_dict() -> Dictionary:
	var d = {"visual_nodes": [], "edges": []}
	for node in visual_nodes:
		d["visual_nodes"].append("%d,%d,%d,%s,%s" % [node.id, node.position.x, node.position.y, VisualGraphNode.NodeType.keys()[node.node_type], RuleGraphNode.Annotation.keys()[node.annotation]])
	for con in connections:
		d["edges"].append("%d,%d,%s" % [con.a().id, con.b().id, Connection.ConnectionType.keys()[con.connection_type]])
	return d
	
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

func copy_graph(graph: VisualGraph) -> void:
	var node_map = {}
	var con_map = {}
	for node in graph.visual_nodes:
		node_map[node] = copy_node(node)	
	for con in graph.connections:
		var new_con = copy_con(con)
		new_con.set_connection_nodes(node_map[con.connection_nodes[0]], node_map[con.connection_nodes[1]])
		node_map[con.connection_nodes[0]].add_connection(new_con)
		node_map[con.connection_nodes[1]].add_connection(new_con)
		

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
	for node in visual_nodes:
		node.queue_free()
	free_ids.clear()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
const ITERATIONS := 10000
const AREA := Vector2(800, 600)
const REPULSION := 5000.0
const ATTRACTION := 0.0001
const MAX_DISPLACEMENT := 200.0

func apply_force_layout():
	#randomize()
	var disp := {}
	var width = AREA.x
	var height = AREA.y
	var temperature = width / 10.0

	# Add jitter to break symmetry
	for node in visual_nodes:
		node.position += Vector2(randf_range(-50, 50), randf_range(-50, 50))

	for i in ITERATIONS:
		for v in visual_nodes:
			disp[v] = Vector2.ZERO

		# Repulsive forces
		for v in visual_nodes:
			for u in visual_nodes:
				if u == v:
					continue
				var delta = v.position - u.position
				var distance = max(1.0, delta.length())
				var force = REPULSION / (distance * distance)
				disp[v] += delta.normalized() * force

		# Attractive forces along edges
		for con in connections:
			if con.connection_type == Connection.ConnectionType.Relational: continue
			var u = con.a()
			var v = con.b()
			var delta = u.position - v.position
			var distance = max(1.0, delta.length())
			var force = (distance * distance) * ATTRACTION
			var dir = delta.normalized()
			disp[u] -= dir * force
			disp[v] += dir * force

		# Move visual_nodes based on force, clamp within area
		for v in visual_nodes:
			var d = disp[v]
			d = d.normalized() * min(d.length(), temperature)
			v.position += d
			v.position.x = clamp(v.position.x, 0, width)
			v.position.y = clamp(v.position.y, 0, height)

		# Reduce temperature each iteration (annealing)
		#temperature *= 0.95
			
	for con in connections:
		con.update_connection_position()

const max_lock_checks = 100

func is_traversable() -> bool:
	var visited = {}
	var queue = []
	var inventory = []
	var lock_checks = 0

	var start_node = get_entrance_node()
	if not start_node:
		return false
	queue.append(start_node)

	while queue.size() > 0:
		var current = queue.pop_front()

		if visited.has(current.id):
			continue
			
		if lock_checks > max_lock_checks:
			print("not valid")
			return false
			
		# only add the lock's neighbours if its locks have all been visited, put the lock back in the queue
		if current.node_type == VisualGraphNode.NodeType.LOCK:
			var keys = get_lock_keys(current)
			if not keys.all(func(x): return visited.has(x.id)):
				queue.append(current)
				lock_checks += 1
				continue
		
		

		if not visited.has(current.id):
			visited[current.id] = []
		
		# Goal reached
		if current.node_type == VisualGraphNode.NodeType.GOAL:
			print("valid")
			return true
			
		

		for neighbour in get_neighbours(current):
			queue.append(neighbour)

	print("not valid")
	return false  # goal unreachable
	
func has_no_intersection() -> bool:
	print(connections.size())
	for i in connections.size():
		if connections[i].connection_type == Connection.ConnectionType.Relational: continue
		var ab1 = connections[i].b().position - connections[i].a().position
		for j in range(i + 1, connections.size()):
			if connections[j].connection_type == Connection.ConnectionType.Relational: continue
			var ab2 = connections[j].b().position - connections[j].a().position
			if Geometry2D.segment_intersects_segment(connections[i].a().position + ab1 * 0.1, connections[i].b().position - ab1 * 0.1, connections[j].a().position + ab2 * 0.1, connections[j].b().position - ab2 * 0.1) != null:
				print("overlap_found at %d, %d" % [i, j])
				return false
			
	return true
	
func ccw(A,B,C):
	return (C.position.y-A.position.y) * (B.position.x-A.position.x) > (B.position.y-A.position.y) * (C.position.x-A.position.x)

# Return true if line segments AB and CD intersect
func intersect(a: Connection, b: Connection):
	return ccw(a.a(),b.a(),b.b()) != ccw(a.b(),b.a(),b.b()) and ccw(a.a(),a.b(),b.a()) != ccw(a.a(),a.b(),b.b())
	
func lines_intersect(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> Array:
	var intersection_point = Vector2()
	var intersects = false

	# Denominator for the intersection formula
	var den = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x)

	# If den is 0, the lines are parallel or collinear.
	if den == 0:
		# Check for collinearity and overlap.
		# If they are collinear, they might "intersect" over a segment.
		# For simplicity, we'll consider them intersecting if they overlap.
		# This is a more complex check, usually involving projecting one segment onto the other.
		# For this function, if den is 0, we'll return false, as a single intersection point isn't well-defined.
		# If you need to handle collinear overlapping segments as intersecting, you'd add more logic here.
		return [false, intersection_point]

	# Numerator for t (parameter for line 1)
	var t_num = (p1.x - p3.x) * (p3.y - p4.y) - (p1.y - p3.y) * (p3.x - p4.x)
	# Numerator for u (parameter for line 2)
	var u_num = (p1.x - p2.x) * (p1.y - p3.y) - (p1.y - p2.y) * (p1.x - p3.x)

	var t = t_num / den
	var u = u_num / den

	# If 0 <= t <= 1 and 0 <= u <= 1, the line segments intersect
	if t >= 0 && t <= 1 && u >= 0 && u <= 1:
		intersects = true
		# Calculate the intersection point
		intersection_point.x = p1.x + t * (p2.x - p1.x)
		intersection_point.y = p1.y + t * (p2.y - p1.y)

	return [intersects, intersection_point]

func get_entrance_node() -> RuleGraphNode:
	return visual_nodes.filter(func(x): return x.node_type == VisualGraphNode.NodeType.ENTRANCE)[0]

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
