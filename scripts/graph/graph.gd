extends Control

var nodes: Array[MyGraphNode] = []
var connections: Array[Connection] = []


func _ready() -> void:	
	child_entered_tree.connect(on_child_entered)
	
	
func on_child_entered(child: Node) -> void:
	if child is MyGraphNode:
		nodes.append(child)
		child.moved.connect(on_node_moved)
	if child is Connection:
		connections.append(child)		
	

func on_node_moved(node: Control) -> void:
	# update the connection
	for con in connections:
		if con.belongs_to_graph_node(node):
			con.update_connection_position()

func _on_button_pressed() -> void:
	var p = (load("res://scripts/graph_node/graph_node.tscn") as PackedScene).instantiate()
	
	add_child(p)
	p.set_position(Vector2(200,200))
