@tool
extends Control
class_name Draggable

signal drag_started(node: Control, global_mouse: Vector2)
signal drag_moved(node: Control, global_mouse: Vector2)
signal drag_ended(node: Control)

var _is_dragging: bool = false

func _ready() -> void:
	set_position(Vector2.ZERO)
	set_size(get_parent().size)
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton and not event is InputEventMouseMotion:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var rect = Rect2(position, size)
			if rect.has_point(event.position):
				print("start dragging")
				_is_dragging = true
				get_viewport().set_input_as_handled()
				drag_started.emit(get_parent(), event.position)
		else:
			if _is_dragging:
				print("stopped dragging")
				_is_dragging = false
				get_viewport().set_input_as_handled()
				drag_ended.emit(get_parent())

	if event is InputEventMouseMotion and _is_dragging:
		print("dragging")
		get_viewport().set_input_as_handled()
		drag_moved.emit(get_parent(), event.position)
