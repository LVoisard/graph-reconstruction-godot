extends Control

var nodes: Array[MyGraphNode] = []
var connections: Array[Connection] = []


func _ready() -> void:	
	child_entered_tree.connect(on_child_entered)
	child_exiting_tree.connect(on_child_exited)
	
	
func on_child_entered(child: Node) -> void:
	if child is MyGraphNode:
		move_child(child, -1)
		nodes.append(child)
	if child is Connection:
		move_child(child, 0)
		connections.append(child)

func on_child_exited(child: Node) -> void:
	if child is MyGraphNode:
		if child in nodes:
			nodes.remove_at(nodes.find(child))
	if child is Connection:
		if child in connections:
			connections.remove_at(connections.find(child))
