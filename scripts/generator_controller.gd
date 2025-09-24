class_name Generator extends Control

signal graph_complete

const generator_rule_prefab: PackedScene = preload("res://scenes/generator_rule.tscn")

@onready var generator_rules_container: Control = $"HBoxContainer/Left Bar/Panel/HBoxContainer/TabContainer/Manual/VBoxContainer"
@onready var generator_graph: VisualGraph = $"HBoxContainer/Input Graph Viewport/SubViewport/Control/input graph"
@onready var recipes: Recipes = $"HBoxContainer/Left Bar/Panel/HBoxContainer/TabContainer/Recipes"


func _ready() -> void:
	recipes.apply_rule_random.connect(apply_rule_random)
	recipes.apply_rule_lsystem.connect(apply_rule_lsystem)
	recipes.organise_graph.connect(organise_graph)
	recipes.recipe_complete.connect(validate_graph)
	recipes.update_gaph_visual.connect(update_graph_visual)
	refresh_rules()
	clear()
	#Dungeon.Graph()
	
	#clear()
	
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_O):
		organise_graph()
	elif Input.is_key_pressed(KEY_F):
		force_update()
	

func clear() -> void:
	generator_graph.clear_all()
	var entrance = generator_graph.create_new_node() as VisualGraphNode
	entrance.set_position(Vector2(100, 50))
	generator_graph.change_node_type(entrance, VisualGraphNode.NodeType.ENTRANCE)
	generator_graph.update_node_position(entrance)
	
	
	var goal = generator_graph.create_new_node() as VisualGraphNode
	goal.set_position(Vector2(300, 50))
	generator_graph.change_node_type(goal, VisualGraphNode.NodeType.GOAL)
	generator_graph.update_node_position(goal)
	
	generator_graph.create_new_connection(entrance, goal) as Connection
	
	

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
		r.random_apply_btn.button_down.connect(update_graph_visual)
		r.lsystem_apply_btn.button_down.connect(apply_rule_lsystem.bind(file))
		r.lsystem_apply_btn.button_down.connect(update_graph_visual)
		
func update_graph_visual() ->void:
	#generator_graph.backend.ArrangeForceDirected(1480,900, 10000, 150, 10)
	generator_graph.create_visuals_from_backend()
	
func apply_rule_random(file: String) -> void:
	print("Random " + file)
	var patterns = GodotGraph.ParseRuleFromString(FileAccess.get_file_as_string("res://rules/"+file))

	var matches = SubgraphIsomorphism.FindAll(patterns[0], generator_graph.backend)
	print("Found %d matches" % matches.size())	
	if matches.is_empty():
		print("No valid nodes")
		return	
	generator_graph.backend.ApplyRewrite(matches.pick_random(), patterns[0], patterns[1])
	
func apply_rule_lsystem(file: String) -> void:
	print("L-System " + file)
	var patterns = GodotGraph.ParseRuleFromString(FileAccess.get_file_as_string("res://rules/"+file))
	#traverse_graph(graphs[0])
	var matches = SubgraphIsomorphism.FindAll(patterns[0], generator_graph.backend)
	
	print("Found %d matches" % matches.size())
	
	if matches.is_empty():
		print("No valid nodes")
		return
	for m in matches:
		generator_graph.backend.ApplyRewrite(m, patterns[0], patterns[1])
	
func validate_graph() -> bool:
	#generator_graph.backend.ArrangeCustomBFS(true, 150, 200, 0, 500)
	#for i in range(0, 200):
	generator_graph.backend.ArrangeForceDirected(600,600, 1000, 100, 100)
	#var side = ceil(sqrt(generator_graph.backend.GetVertices().size() * 2)) as int
	#generator_graph.backend.ArrangeGrid(100, 400)
	#generator_graph.backend.PlaceOnGrid(7, 7)
	#generator_graph.backend.ArrangeCustomBFS(true, 100, 100, 100, 500)
	#generator_graph.backend.SnapToGrid(100);
	generator_graph.update_visuals_from_backend()
	var valid = generator_graph.backend.IsTraversable() && !generator_graph.backend.HasOverlappingDirectionalEdges()
	print("Valid graph ?", valid)
	return valid

func restart_validation() -> void:
	print("Bad")
	recipes.reset_recipe()
	recipes.complete_recipe()

func organise_graph() -> void:
	#generator_graph.backend.ArrangeCustomBFS(true, 150, 200, 0, 500)
	#generator_graph.backend.ArrangeForceDirected(10000,10000, 100, 75, 10)
	generator_graph.create_visuals_from_backend()
	
var nb_iter = 0
func force_update() -> void:
	generator_graph.backend.ArrangeForceDirected(600,600, 1000, 75, 100)
	nb_iter += 10
	print(nb_iter)
	generator_graph.update_visuals_from_backend()
	
func generate_dungeon_graph(recipe_path: String) -> VisualGraph:
	clear()
	recipes.load_recipe(recipe_path)
	recipes.complete_recipe()
	while !validate_graph():
		clear()
		restart_validation()
	return generator_graph
		
	
