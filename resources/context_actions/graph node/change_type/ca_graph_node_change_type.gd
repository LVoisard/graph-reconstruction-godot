extends ContextAction

@export var type: VisualGraphNode.NodeType

func perform_context_action(node: Node) -> void:
	var g_node = node as VisualGraphNode
	g_node.set_type(type)
	
