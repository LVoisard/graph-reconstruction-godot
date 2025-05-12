extends Control
class_name MyGraphNode

signal moved
signal deleted

@onready var draggable: Draggable = $"draggable"

func _ready() -> void:
	draggable.dragging.connect(on_moved)
	draggable.finished_dragging.connect(on_moved)
	
	
func on_moved() -> void:
	moved.emit()
	
func _exit_tree() -> void:
	deleted.emit()

enum NodeType {
	ENTRANCE,
	GOAL,
	TASK,
	KEY,
	LOCK,
	ANY,
}
