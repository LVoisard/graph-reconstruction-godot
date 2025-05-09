extends Node
class_name MyGraphNode

signal moved(node)

@onready var draggable: Draggable = $"draggable"

func _ready() -> void:
	draggable.finished_dragging.connect(on_moved)
	
	
func on_moved() -> void:
	moved.emit(self)

enum NodeType {
	ENTRANCE,
	GOAL,
	TASK,
	KEY,
	LOCK,
	ANY,
}
