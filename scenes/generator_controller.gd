extends Control

const generator_rule_prefab: PackedScene = preload("res://scenes/generator_rule.tscn")

@onready var generator_rules_container: Control = $"HBoxContainer/Left Bar/Panel/MarginContainer/VBoxContainer"
@onready var generator_graph: MyGraph = $"HBoxContainer/Input Graph Viewport/SubViewport/Control/input graph"

func _ready() -> void:
	var dir = DirAccess.open("res://rules")
	var files = dir.get_files()
	print(files)
	for file in files:
		var r = generator_rule_prefab.instantiate()
		generator_rules_container.add_child(r)
		var n = file.get_basename()
		r.label.text = n
		r.random_apply_btn.button_down.connect(apply_rule_random.bind(file))
		r.lsystem_apply_btn.button_down.connect(apply_rule_lsystem.bind(file))
	var entrance = load("res://scripts/graph_node/graph_node.tscn").instantiate() as MyGraphNode
	var goal = load("res://scripts/graph_node/graph_node.tscn").instantiate() as MyGraphNode
	var con = load("res://scripts/connection/connection.tscn").instantiate() as Connection
	generator_graph.add_child(entrance)
	generator_graph.add_child(goal)
	entrance.position = Vector2(100, get_viewport_rect().get_center().y)
	goal.position = Vector2(300, get_viewport_rect().get_center().y)
	entrance.set_type(MyGraphNode.NodeType.ENTRANCE)
	goal.set_type(MyGraphNode.NodeType.GOAL)
	con.set_connection_nodes(entrance, goal)
	entrance.add_connection(con)
	goal.add_connection(con)
	generator_graph.add_child(con)

func apply_rule_random(file: String) -> void:
	var graphs = Helper.parse_graphs("res://rules/"+file)
	traverse_graph(graphs[0])
	print("Random " + file)
	
func apply_rule_lsystem(file: String) -> void:
	print("L-System " + file)


func traverse_graph(input: Dictionary) -> void:
	var max_length = input["nodes"].size()
	var visited_nodes: Array = []
	var node_stack: Array = [generator_graph.nodes[0]]
	var depth = 0
	while not node_stack.is_empty():
		var node = node_stack.pop_back() as MyGraphNode
		if node in visited_nodes: continue		
		visited_nodes.append(node)		
		for c in node.connections:
			var con = c as Connection
			node_stack.append(con.get_other(node))
