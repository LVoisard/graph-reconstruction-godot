extends ContextAction

@export var type: Connection.ConnectionType

func perform_context_action(node: Node) -> void:
	var g_node = node as Connection
	g_node.set_type(type)
	
