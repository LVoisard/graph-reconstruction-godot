extends ContextAction
var prefab: PackedScene = null
func perform_context_action(node: Node) -> void:
	print("creating new node")
	if prefab == null:
		prefab = load("res://scripts/graph_node/graph_node.tscn")
		
	var inst = prefab.instantiate() as Control
	inst.position = node.get_global_mouse_position() - inst.get_rect().size / 2
	node.add_child(inst)
