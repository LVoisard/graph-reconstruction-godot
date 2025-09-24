class_name ContextMenu
extends Control

var mouse_over_parent: bool = false

@export var context: String
@export var context_actions: Array[ContextAction] = []

@onready var context_label = $"v-container/context-label"
@onready var context_actions_container = $"v-container/context-actions"

func _ready() -> void:
	if get_parent() == get_tree().root:
		printerr("Context-Menu \"%s\" has no parent" % context)
	context_label.text = context
	
	get_parent().mouse_entered.connect(on_mouse_entered)
	get_parent().mouse_exited.connect(on_mouse_exited)
	
	for context_action in context_actions:
		if context_action is SubContextAction:
			var ca = context_action as SubContextAction
			var btn = MenuButton.new()
			btn.text = ca.get_action_name()
			btn.flat = false
			for action in ca.sub_context_actions:
				btn.get_popup().add_item(action.get_action_name())
			btn.get_popup().id_pressed.connect(ca.on_sub_context_action_clicked.bind(get_parent()))	
			btn.get_popup().id_pressed.connect(on_sub_context_action_pressed)
			context_actions_container.add_child(btn)
		elif context_action is ContextAction:
			var ca = context_action as ContextAction
			var btn = Button.new()
			btn.text = ca.get_action_name()
			btn.pressed.connect(ca.perform_context_action.bind(get_parent())) 
			btn.pressed.connect(on_context_action_pressed)
			context_actions_container.add_child(btn)
		
	self.hide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			if mouse_over_parent:
				self.visible = true
				self.global_position = get_global_mouse_position()
				get_parent().get_parent().move_child(get_parent(), -1)
			else:
				self.visible = false
	elif event is InputEventMouseButton:
		if not get_global_rect().has_point(get_global_mouse_position()):
				self.visible = false

func on_mouse_entered() -> void:
	mouse_over_parent = true
	
func on_mouse_exited() -> void:
	mouse_over_parent = false
	
	
func on_sub_context_action_pressed(_id: int) -> void:
	self.visible = false
	
func on_context_action_pressed() -> void:
	self.visible = false
