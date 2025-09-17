extends GraphNodeContextAction

@export var type: VisualGraphNode.NodeType

func perform_graph_node_context_action(node: VisualGraphNode) -> void:
	node.graph.change_node_type(node, type)
	
