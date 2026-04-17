@tool
extends EditorPlugin

var dock_contents

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock_contents = preload("res://scenes/generator.tscn").instantiate()
	
	get_editor_interface().get_editor_main_screen().add_child(dock_contents)
	print(dock_contents.is_node_ready())
	



func _exit_tree() -> void:
	if dock_contents:
		dock_contents.queue_free()
		dock_contents = null

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if dock_contents:
		dock_contents.visible = visible
		
func _get_plugin_icon() -> Texture2D:
	return preload("res://addons/lv_graph/code-branch-solid.png")

func _get_plugin_name() -> String:
	return "LV Gen"
