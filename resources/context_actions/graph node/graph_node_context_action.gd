class_name GraphNodeContextAction
extends ContextAction

func perform_graph_node_context_action(_node: VisualGraphNode) -> void:
	print("performing graph node action")
	
func perform_context_action(_node: Node) -> void:
	self.perform_graph_node_context_action((_node as VisualGraphNode))
	
