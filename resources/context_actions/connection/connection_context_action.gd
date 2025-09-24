class_name ConnectionContextAction
extends ContextAction

func perform_connection_context_action(con: Connection) -> void:
	print("performing connection action")

func perform_context_action(_node: Node) -> void:
	perform_connection_context_action(_node as Connection)
