class_name GraphContextAction
extends ContextAction

func perform_graph_context_action(_node: VisualGraph) -> void:
	print("performing action")
	
func perform_context_action(_node: Node) -> void:
	self.perform_graph_context_action((_node as VisualGraph))
	
