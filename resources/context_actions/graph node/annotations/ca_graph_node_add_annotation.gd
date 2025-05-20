extends ContextAction

@export var type: RuleGraphNode.Annotation

func perform_context_action(node: Node) -> void:
	var g_node = node as RuleGraphNode
	g_node.set_annotation(type)
