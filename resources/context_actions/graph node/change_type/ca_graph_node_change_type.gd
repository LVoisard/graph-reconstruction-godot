extends ContextAction

@export var type: MyGraphNode.NodeType

func perform_context_action(node: Node) -> void:
	var g_node = node as MyGraphNode
	g_node.set_type(type)
	
