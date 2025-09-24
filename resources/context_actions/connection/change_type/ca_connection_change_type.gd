extends ConnectionContextAction

@export var type: Connection.ConnectionType

func perform_connection_context_action(node: Connection) -> void:
	node.graph.change_connection_type(node, type)
	
