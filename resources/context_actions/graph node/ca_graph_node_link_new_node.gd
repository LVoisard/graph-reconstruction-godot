extends ContextAction

var node_prefab: PackedScene = null
var connection_prefab: PackedScene = null

func perform_context_action(node: Node) -> void:
	if node_prefab == null:
		node_prefab = load("res://scripts/graph_node/rule/rule_graph_node.tscn")
	if connection_prefab == null:
		connection_prefab = load("res://scripts/connection/connection.tscn")
	var n = node_prefab.instantiate() as RuleGraphNode
	node.add_sibling(n)
	n.set_global_position(node.get_position() + Vector2(150, 0))
	
	var c = connection_prefab.instantiate() as Connection
	node.add_sibling(c)
	c.set_connection_nodes(node as RuleGraphNode, n)
	node.add_connection(c)
	n.add_connection(c)
	
	
