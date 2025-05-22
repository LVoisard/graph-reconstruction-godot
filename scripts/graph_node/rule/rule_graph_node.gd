class_name RuleGraphNode extends MyGraphNode

var annotation: Annotation = Annotation.None

func set_annotation(ann: Annotation) -> void:
	annotation = ann

enum Annotation {
	None,
	Moved,
	KeepIncomingConnections,
	KeppOutgoingConnections,
	KeepConnections,
	Removed
}
