extends Control
class_name Connection 

var connection_nodes: Array[MyGraphNode] = [null, null]
var connector_bits: Array[bool] = [false,true]
var connection_type: ConnectionType = ConnectionType.Directional

@export var connector_arrow: Texture2D
@export var connector_dead_end: Texture2D

@onready var left_connector: TextureButton = $"HBoxContainer/left connector"
@onready var right_connector: TextureButton = $"HBoxContainer/right connector"
@onready var dotted_line: TextureRect = $"HBoxContainer/dotted_line"
@onready var full_line: NinePatchRect = $"HBoxContainer/full_line"

func _ready() -> void:
	left_connector.button_down.connect(on_connector_button_pressed.bind(0))
	right_connector.button_down.connect(on_connector_button_pressed.bind(1))
	update_connection_visual()

func set_connection_nodes(_a: MyGraphNode, _b: MyGraphNode) -> void:
	connection_nodes[0] = _a
	connection_nodes[1] = _b	
	a().moved.connect(update_connection_position)
	b().moved.connect(update_connection_position)
	a().deleted.connect(on_connection_deleted)
	b().deleted.connect(on_connection_deleted)
	update_connection_position()
	
	
func update_connection_position() -> void:
	var ab: Vector2 = b().get_global_rect().get_center() - a().get_global_rect().get_center()
	var ab_dir: Vector2 = ab.normalized()
	
	size.x = ab.length() - a().size.x / 2 - b().size.x / 2
	position = a().get_rect().get_center() + ab / 2 - size / 2
	
	pivot_offset = size / 2
	rotation = ab_dir.angle()
	
func update_connection_visual() -> void:
	left_connector.texture_normal = connector_arrow if connector_bits[0] else connector_dead_end
	right_connector.texture_normal = connector_arrow if connector_bits[1] else connector_dead_end
	right_connector.flip_h = true
	
	match connection_type:
		ConnectionType.Directional:
			left_connector.show()
			right_connector.show()
			dotted_line.hide()
			full_line.show()
		ConnectionType.Relational:
			left_connector.hide()
			right_connector.show()
			dotted_line.show()
			full_line.hide()
	
func set_type(new_type: ConnectionType) -> void:
	print("%s > %s" % [ConnectionType.keys()[connection_type], ConnectionType.keys()[new_type]])
	connection_type = new_type
	update_connection_visual()
	
func belongs_to_graph_node(node: MyGraphNode) -> bool:
	return a() == node || b() == node	

func get_other(node: MyGraphNode) -> MyGraphNode:
	return a() if node == b() else b()

func a() -> MyGraphNode:
	return connection_nodes[0]
	
func b() -> MyGraphNode:
	return connection_nodes[1]

func on_connection_deleted(node: Node) -> void:
	if node != a() && a() != null: a().remove_connection(self)
	if node != b() && b() != null: b().remove_connection(self)
	self.queue_free()
	
func on_connector_button_pressed(index: int)->void:
	connector_bits[index] = !connector_bits[index]
	if not connector_bits[0] && not connector_bits[1]:
		connector_bits[(index + 1) % 2] = true
	update_connection_visual()
	
func copy_connector(con: Connection) -> void:	
	self.connection_type = con.connection_type
	self.connector_bits = con.connector_bits
	update_connection_visual()
	

enum ConnectionType {
	Directional,
	Relational
}
