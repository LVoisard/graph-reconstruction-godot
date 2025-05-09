extends Control
class_name Connection 

var connection_nodes: Array[Control] = [null, null]
var connector_bits: Array[bool] = [false,false]
var connection_type: ConnectionType = ConnectionType.Directional



func set_connection_nodes(_a: Control, _b: Control) -> void:
	connection_nodes[0] = _a
	connection_nodes[1] = _b
	
	
func update_connection_position() -> void:
	print("hello")
	var ab: Vector2 = b().get_global_rect().get_center() - a().get_global_rect().get_center()
	
	var ab_dir: Vector2 = ab.normalized()
	print(ab)
	print(ab_dir)
	
	
	
	var angle: float = ab_dir.angle()
	size.x = ab.length() - a().size.x / 2 - b().size.x / 2
	position = a().get_rect().get_center() + ab / 2 - size / 2
	
	print("position ", global_position)
	print("ab ", ab)
	print("a ", a().get_global_rect().get_center())
	print("b ", b().get_global_rect().get_center())
	
	pivot_offset = size / 2
	rotation = angle
	
func belongs_to_graph_node(node: Control) -> bool:
	return a() == node || b() == node
	

func a() -> Control:
	return connection_nodes[0]
	
func b() -> Control:
	return connection_nodes[1]

enum ConnectionType {
	Directional,
	Relational
}
