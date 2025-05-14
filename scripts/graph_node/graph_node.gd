extends Control
class_name MyGraphNode

signal moved
signal deleted(node)

@export var outline_texture_round: Texture2D = null
@export var visual_texture_round: Texture2D = null
@export var outline_texture_square: Texture2D = null
@export var visual_texture_square: Texture2D = null

@onready var draggable: Draggable = $"draggable"
@onready var outline: TextureRect = $"Outline"
@onready var visual: TextureRect = $"Outline/NodeVisual"
@onready var label: Label = $"Outline/NodeVisual/Label"


var node_type: NodeType = NodeType.ANY
var connections: Array[Connection] = []
var id: int = -1

func _ready() -> void:
	draggable.dragging.connect(on_moved)
	draggable.finished_dragging.connect(on_moved)
	set_type(NodeType.ANY)
	
func set_id(id: int) -> void:
	self.id = id

func set_type(new_type: NodeType) -> void:
	print("%s > %s" % [NodeType.keys()[node_type], NodeType.keys()[new_type]])
	node_type = new_type
	label.text = "%d:%s" % [id, NodeType.keys()[node_type].substr(0,1)]
	change_visuals()
	
func change_visuals() -> void:
	match node_type:
		NodeType.ANY:
			outline.texture = outline_texture_round
			visual.texture = visual_texture_round
			visual.self_modulate = Color.WHITE
			label.self_modulate = Color.BLACK
		NodeType.ENTRANCE:
			outline.texture = outline_texture_round
			visual.texture = visual_texture_round
			visual.self_modulate = Color.SEA_GREEN
			label.self_modulate= Color.WHITE
		NodeType.GOAL:
			outline.texture = outline_texture_round
			visual.texture = visual_texture_round
			visual.self_modulate = Color.SEA_GREEN
			label.self_modulate = Color.WHITE
		NodeType.TASK:
			outline.texture = outline_texture_square
			visual.texture = visual_texture_square
			visual.self_modulate = Color.WHITE
			label.self_modulate = Color.BLACK
		NodeType.KEY:
			outline.texture = outline_texture_square
			visual.texture = visual_texture_square
			visual.self_modulate = Color.SEA_GREEN
			label.self_modulate = Color.BLACK
		NodeType.LOCK:
			outline.texture = outline_texture_square
			visual.texture = visual_texture_square
			visual.self_modulate = Color.BLACK
			label.self_modulate = Color.WHITE
	
	
func on_moved() -> void:
	moved.emit()
	
func add_connection(con: Connection) -> void:
	connections.append(con)
	
func remove_connection(con: Connection) -> void:
	if con in connections:
		connections.remove_at(connections.find(con))

func remove_all_connections() -> void:
	for conn in connections:
		conn.on_connection_deleted(self)
	connections.clear()
	
func _exit_tree() -> void:
	deleted.emit(self)
	
func copy_node(node: MyGraphNode) -> void:
	self.set_type(node.node_type)
	self.set_position(node.position)

enum NodeType {
	ENTRANCE,
	GOAL,
	TASK,
	KEY,
	LOCK,
	ANY,
}
