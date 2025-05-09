extends Control
class_name Draggable

signal finished_dragging

var is_dragging = false #state management
var mouse_offset #center mouse on click


var mouse_over_parent: bool = false

func _ready() -> void:
	self.set_size(get_parent().size)
	self.set_position(get_parent().position)
	get_parent().mouse_entered.connect(on_mouse_entered)
	get_parent().mouse_exited.connect(on_mouse_exited)
	
func _physics_process(delta):
	if is_dragging == true:
		get_parent().position = get_global_mouse_position() - mouse_offset
		
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if mouse_over_parent:
				#print('clicked on sprite')
				is_dragging = true
				mouse_offset = get_global_mouse_position() - get_parent().global_position
		else:
			if is_dragging:
				finished_dragging.emit()
			is_dragging = false
			

func on_mouse_entered() -> void:
	mouse_over_parent = true
	
func on_mouse_exited() -> void:
	mouse_over_parent = false
