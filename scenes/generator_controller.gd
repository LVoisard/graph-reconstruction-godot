class_name Generator extends Control

signal graph_complete

const generator_rule_prefab: PackedScene = preload("res://scenes/generator_rule.tscn")

@onready var generator_rules_container: Control = $"HBoxContainer/Left Bar/Panel/HBoxContainer/TabContainer/Manual/VBoxContainer"
@onready var generator_graph: MyGraph = $"HBoxContainer/Input Graph Viewport/SubViewport/Control/input graph"
@onready var recipes: Recipes = $"HBoxContainer/Left Bar/Panel/HBoxContainer/TabContainer/Recipes"


func _ready() -> void:
	recipes.apply_rule_random.connect(apply_rule_random)
	recipes.apply_rule_lsystem.connect(apply_rule_lsystem)
	recipes.organise_graph.connect(organise_graph)
	recipes.recipe_complete.connect(validate_graph)
	refresh_rules()
	#clear()
	

func clear() -> void:
	await generator_graph.clear()
	var entrance = load("res://scripts/graph_node/rule/rule_graph_node.tscn").instantiate() as MyGraphNode
	var goal = load("res://scripts/graph_node/rule/rule_graph_node.tscn").instantiate() as MyGraphNode
	var c = load("res://scripts/connection/connection.tscn").instantiate() as Connection
	generator_graph.add_child(entrance)
	entrance.position = Vector2(100, 100)
	entrance.set_type(MyGraphNode.NodeType.ENTRANCE)	
	goal.position = entrance.position + Vector2(800, 700)
	generator_graph.add_child(goal)
	goal.set_type(MyGraphNode.NodeType.GOAL)
	c.set_connection_nodes(entrance, goal)
	entrance.add_connection(c)
	goal.add_connection(c)
	generator_graph.add_child(c)

func refresh_rules() -> void:
	var dir = DirAccess.open("res://rules")
	var files = dir.get_files()
	for child in generator_rules_container.get_children():
		child.free()
		
	for file in files:
		var r = generator_rule_prefab.instantiate()
		generator_rules_container.add_child(r)
		var n = file.get_basename()
		r.label.text = n
		r.random_apply_btn.button_down.connect(apply_rule_random.bind(file))
		r.lsystem_apply_btn.button_down.connect(apply_rule_lsystem.bind(file))

func apply_rule_random(file: String) -> void:
	var graphs = Helper.parse_graphs("res://rules/"+file)
	var target = AnalyticGraph.new(generator_graph.get_graph_dict())
	var pattern = AnalyticGraph.new(graphs[0])
	var pattern_output = AnalyticGraph.new(graphs[1])
	#traverse_graph(graphs[0])
	var matches = find_subgraph_matches(target, pattern)
	print("Found %d matches" % matches.size())
	
	if matches.is_empty():
		print("No valid nodes")
		return
	
	apply_rewrite(target, matches.pick_random(),pattern, pattern_output)
	
	await generator_graph.clear()
	await get_tree().process_frame
	generator_graph.load_from_analytic(target)
	print("Random " + file)
	
func apply_rule_lsystem(file: String) -> void:
	var graphs = Helper.parse_graphs("res://rules/"+file)
	var target = AnalyticGraph.new(generator_graph.get_graph_dict())
	var pattern = AnalyticGraph.new(graphs[0])
	var pattern_output = AnalyticGraph.new(graphs[1])
	#traverse_graph(graphs[0])
	var matches = find_subgraph_matches(target, pattern)
	print("Found %d matches" % matches.size())
	
	if matches.is_empty():
		print("No valid nodes")
		return
	for m in matches:
		apply_rewrite(target, m, pattern, pattern_output)
		
	
	await generator_graph.clear()
	generator_graph.load_from_analytic(target)
	
	print("L-System " + file)

func find_subgraph_matches(G: AnalyticGraph, P: AnalyticGraph) -> Array:
	var results = []
	var mapping = {}
	var used_G_nodes = {}

	backtrack(G, P, mapping, used_G_nodes, results)
	return results

func backtrack(G: AnalyticGraph, P: AnalyticGraph, mapping: Dictionary, used_G_nodes: Dictionary, results: Array):
	if mapping.size() == P.nodes.size():
		results.append(mapping.duplicate(true))
		return

	var next_p_node = select_next_pattern_node(P, mapping)
	for g_node_id in G.nodes.keys():
		if used_G_nodes.has(g_node_id):
			continue
		if nodes_compatible(P.nodes[next_p_node], G.nodes[g_node_id]) and edges_compatible(P, G, mapping, next_p_node, g_node_id):
			
			mapping[next_p_node] = g_node_id
			used_G_nodes[g_node_id] = true

			backtrack(G, P, mapping, used_G_nodes, results)

			mapping.erase(next_p_node)
			used_G_nodes.erase(g_node_id)

func select_next_pattern_node(P: AnalyticGraph, mapping: Dictionary) -> int:
	for node_id in P.nodes.keys():
		if not mapping.has(node_id):
			return node_id
	return -1

func nodes_compatible(p_node: AnalyticGraph.AnalyticGraphNode, g_node: AnalyticGraph.AnalyticGraphNode) -> bool:
	return p_node.label == "ANY" || p_node.label == g_node.label

func edges_compatible(P: AnalyticGraph, G: AnalyticGraph, mapping: Dictionary, new_p_node: int, candidate_g_node: int) -> bool:
	# Check all required edges from the pattern exist in the target
	for p_edge in P.edges:
		var p_src = p_edge.source
		var p_tgt = p_edge.target
		var g_src = mapping.get(p_src, null)
		var g_tgt = mapping.get(p_tgt, null)

		# Only check if one or both ends are already mapped
		if p_src == new_p_node and g_tgt != null:
			if not edge_exists(G, candidate_g_node, g_tgt, p_edge.label):
				return false
		elif p_tgt == new_p_node and g_src != null:
			if not edge_exists(G, g_src, candidate_g_node, p_edge.label):
				return false
		elif g_src != null and g_tgt != null:
			if not edge_exists(G, g_src, g_tgt, p_edge.label):
				return false

	## Now reject if there are extra edges in the target between mapped nodes
	#var mapped_nodes = mapping.duplicate()
	#mapped_nodes[new_p_node] = candidate_g_node
#
	## Create reverse mapping: from target node ID to pattern node ID
	#var reverse_mapping = {}
	#for p_id in mapped_nodes.keys():
		#reverse_mapping[mapped_nodes[p_id]] = p_id
#
	#for g_edge in G.edges:
		#if reverse_mapping.has(g_edge.source) and reverse_mapping.has(g_edge.target):
			#var p_src = reverse_mapping[g_edge.source]
			#var p_tgt = reverse_mapping[g_edge.target]
#
			#var found = false
			#for p_edge in P.edges:
				#if p_edge.source == p_src and p_edge.target == p_tgt and p_edge.label == g_edge.label:
					#found = true
					#break
				#elif p_edge.source == p_tgt and p_edge.target == p_src and p_edge.label == g_edge.label:
					#found = true
					#break
			#if not found:
				## Extra edge in target that doesn't exist in pattern
				#return false

	return true


func edge_exists(G: AnalyticGraph, src: int, tgt: int, label: String) -> bool:
	for edge in G.edges:
		if edge.source == src and edge.target == tgt and edge.label == label:
			return true
	return false


func apply_rewrite(G: AnalyticGraph, m: Dictionary, pattern_input: AnalyticGraph, pattern_output: AnalyticGraph) -> void:
	# identify which nodes are targeted
	var mapped_nodes = {}
	var mapped_nodes_reversed = {}
	for matched_id in m.keys():
		mapped_nodes[matched_id] = G.nodes[m[matched_id]]
		mapped_nodes_reversed[m[matched_id]] = matched_id
	
	# record the connections to nodes from outside the matched pattern
	# this also includes connection that exist between pattern nodes, not specified in the pattern
	var matched_node_ids = m.values()
	var matched_node_set := {}
	for id in matched_node_ids:
		matched_node_set[id] = true

	var external_edges := []

	for edge in G.edges:
		var src_in_match := matched_node_set.has(edge.source)
		var tgt_in_match := matched_node_set.has(edge.target)

		# Case 1: One side is inside match, one is outside => external edge to preserve
		if src_in_match != tgt_in_match:			
			# check if there is an annotation that tells us what to do, otherwise, link up external nodes like before.
			var id = edge.source if src_in_match else edge.target
			if src_in_match:
				external_edges.append(edge)
			elif tgt_in_match:				
				if edge.label != "Relational":
					external_edges.append(edge)
				elif pattern_input.nodes[mapped_nodes_reversed[id]].annotation == "None":
					external_edges.append(edge)
				else:
					var ann = pattern_input.nodes[mapped_nodes_reversed[id]].annotation
					var other = pattern_output.nodes.values().find_custom(func(x): return x.annotation == ann)
					edge.target = m[other+1]
					external_edges.append(edge)
			#connection is inside the pattern
		elif src_in_match && tgt_in_match:
			if pattern_output.nodes[mapped_nodes_reversed[edge.source]].annotation == "KeepConnections" or pattern_output.nodes[mapped_nodes_reversed[edge.target]].annotation == "KeepConnections":
				external_edges.append(edge)
			elif pattern_output.nodes[mapped_nodes_reversed[edge.target]].annotation == "KeepIncomingConnections":
				external_edges.append(edge)
			elif pattern_output.nodes[mapped_nodes_reversed[edge.source]].annotation == "KeepOutgoingConnections":
				external_edges.append(edge)
	
	#remove connections from the nodes
	for target_graph_node_id in m.values():
		remove_node_and_edges(G, target_graph_node_id)
		
	# add new and previous nodes to the graph
	var new_node_mapped_to_pattern_nodes = {}
	for pattern_node_id in pattern_output.nodes:
		var new_node = null
		# this node is from the input
		if m.has(pattern_node_id) and m[pattern_node_id] in m.values():
			new_node = mapped_nodes[pattern_node_id]
			if pattern_output.nodes[pattern_node_id].label != new_node.label and pattern_output.nodes[pattern_node_id].label != "ANY":
				new_node.label = pattern_output.nodes[pattern_node_id].label
			#print("equivalent node (%d: %d) identified" % [pattern_node_id, m[pattern_node_id]])
		# this node is a new one from the pattern
		else:
			var edge_index = pattern_output.edges.find_custom(func(x): return x.target == pattern_node_id)
			var src = G.nodes[m[pattern_output.edges[edge_index].source]]
			new_node = AnalyticGraph.AnalyticGraphNode.new(G.get_next_id(), src.x + 200, src.y, pattern_output.nodes[pattern_node_id].label, pattern_output.nodes[pattern_node_id].annotation)
			
		G.add_node(new_node)
		new_node_mapped_to_pattern_nodes[pattern_node_id] = new_node.id
		
	# add the edges to the new nodes
	for pattern_edge in pattern_output.edges:
		var new_source = new_node_mapped_to_pattern_nodes[pattern_edge.source]
		var new_target = new_node_mapped_to_pattern_nodes[pattern_edge.target]
		var new_edge = AnalyticGraph.AnalyticGraphEdge.new(new_source, new_target, pattern_edge.label)
		G.add_edge(new_edge)
		
	#add back previous edges
	for external_edge in external_edges:
		G.add_edge(external_edge)
	
	#print(G.to_dict())
	
	

func remove_node_and_edges(G: AnalyticGraph, node_id: int) -> void:
	G.nodes.erase(node_id)
	G.edges = G.edges.filter(func(e): return e.source != node_id and e.target != node_id)
	
func remove_nodes(G: AnalyticGraph, node_id: int) -> void:
	G.nodes.erase(node_id)
func remove_internal_edges(G: AnalyticGraph, node_id: int) -> void:
	G.nodes.erase(node_id)


func get_max_node_id(G: AnalyticGraph) -> int:
	if G.nodes.size() == 0:
		return 0
	return G.nodes.keys().reduce(func(a, b): return max(a, b))
	
	
func validate_graph() -> bool:
	if generator_graph.is_traversable():
		print("Good")
		await organise_graph()
		if not generator_graph.has_no_intersection():
			print("Overlap")
			restart_validation()
			return false
		graph_complete.emit()
	else:
		restart_validation()
	return false

func restart_validation() -> void:
	print("Bad")
	await clear()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	recipes.reset_recipe()
	recipes.complete_recipe()

func organise_graph() -> void:
	await generator_graph.apply_force_layout()	
	
func generate_dungeon_graph(recipe_path: String) -> MyGraph:
	await clear()
	recipes.load_recipe(recipe_path)
	recipes.complete_recipe()
	await graph_complete
	return generator_graph
		
	
