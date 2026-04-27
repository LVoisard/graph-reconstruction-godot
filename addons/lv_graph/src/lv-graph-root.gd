@tool
class_name LVGraphRoot
extends Control

@onready var context_menu: PopupMenu = $"PopupMenu"
	

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			print("RIGHT CLICK at ", event.position)
			_show_context_menu(get_global_mouse_position())
		
func _show_context_menu(pos: Vector2):
	if context_menu:
		context_menu.position = pos
		context_menu.popup()

#func _get_drag_data(at_position: Vector2) -> Variant:
	## Return whatever data you want to drag
	#var preview = Label.new()
	#preview.text = "Dragging!"
	#set_drag_preview(preview)
	#return {"type": "my_node", "pos": at_position}
#
#func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	#return data is Dictionary and data.get("type") == "my_node"
#
#func _drop_data(at_position: Vector2, data: Variant):
	#print("Dropped at ", at_position, " with data ", data)
