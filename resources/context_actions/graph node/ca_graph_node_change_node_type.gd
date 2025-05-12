extends ContextAction

func perform_context_action(node: Node) -> void:
	print("test 1")
	var p = Popup.new()
	node.add_child(p)
	p.popup()
	p.move_to_center()
	
