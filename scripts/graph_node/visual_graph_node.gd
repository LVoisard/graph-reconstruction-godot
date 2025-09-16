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

func _ready() -> void:
	draggable.dragging.connect(on_moved)
	draggable.finished_dragging.connect(on_moved)
	
func set_type(new_type: NodeType) -> void:	
	type = new_type
	label.text = "%d:%s" % [-1, NodeType.keys()[new_type].substr(0,1)]
	change_visuals()
	
func change_visuals() -> void:
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
		NodeType.LOCK_TERMINAL:
			outline.texture = outline_texture_round
			visual.texture = visual_texture_round
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
	LOCK_TERMINAL,
	ANY,
}
