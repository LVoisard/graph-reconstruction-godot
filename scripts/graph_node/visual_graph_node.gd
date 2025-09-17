extends Control
class_name VisualGraphNode

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

var type: NodeType = NodeType.ANY
var id: int
var graph: VisualGraph

func _ready() -> void:
	draggable.dragging.connect(on_moved)
	draggable.finished_dragging.connect(on_moved)
	update_visuals() 
	
func set_graph(graph: VisualGraph) -> void:
	self.graph = graph
	
func set_id(id) -> void:
	self.id = id
	
func set_type(new_type: NodeType) -> void:	
	type = new_type
	
func update_visuals() -> void:
	label.text = "%d:%s" % [id, NodeType.keys()[type].substr(0,1)]
	match type:
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
	
func _exit_tree() -> void:
	deleted.emit(self)
	

enum NodeType {
	ENTRANCE,
	GOAL,
	TASK,
	KEY,
	LOCK,
	ANY,
}
