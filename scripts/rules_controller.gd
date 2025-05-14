extends Control


var file_dialog: FileDialog = null

@onready var input_graph: MyGraph = $"layout container/Center Canvas/Input Graph Viewport/SubViewport/Control/input graph"
@onready var output_graph: MyGraph = $"layout container/Center Canvas/Output Graph Viewport/SubViewport/Control/output graph"

@onready var file_tree:  = $"layout container/Left Bar/Panel/VBoxContainer/Tree" as FileTree

func _ready() -> void:
	file_dialog = load("res://scenes/save_dialog.tscn").instantiate()
	add_child(file_dialog)
	file_dialog.confirmed.connect(save_rule)
	file_tree.load_rule.connect(load_rule)
	update_file_tree()
	
func save_requested() -> void:
	
	file_dialog.show()

func save_rule() -> void:
	var f = FileAccess.open("res://rules/" + file_dialog.current_path, FileAccess.WRITE)
	var s = "input\n"
	s += input_graph.get_graph_string()
	s += "output\n"
	s += output_graph.get_graph_string()
	f.store_string(s)
	f.flush()
	f.close()
	print("saved file at" + "res://rules/" + file_dialog.current_path)
	update_file_tree()

func update_file_tree() -> void:
	file_tree.build_tree()	

func load_rule(path: String) -> void:
	print("loading rule: %s" % path)
	clear()
	await get_tree().process_frame
	await get_tree().process_frame
	var graph_strings = Helper.parse_graphs(path)
	input_graph.load_from_string(graph_strings[0])
	output_graph.load_from_string(graph_strings[1])
	#print(graph_strings)

func copy_to_output() -> void:
	output_graph.copy_graph(input_graph)
	
func clear() -> void:
	input_graph.clear()
	output_graph.clear()
	
