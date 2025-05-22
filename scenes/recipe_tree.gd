class_name RecipeTree extends Tree

signal load_rule(path)

const NAME_COLUMN_INDEX = 0
const MIN_COLUMN_INDEX = 1
const MAX_COLUMN_INDEX = 2
const ACTION_COLUMN_INDEX = 3

var recipe_dict: JsonItemDirectory = null
var new_rule_child: TreeItem = null
var current_step: TreeItem = null

func build_tree(recipe_file: String) -> void:
	clear()
	var scanned_files = get_recipe_rules(recipe_file)
	
	set_column_title(NAME_COLUMN_INDEX, "Name")
	set_column_title(MIN_COLUMN_INDEX, "Min")
	set_column_title(MAX_COLUMN_INDEX, "Max")
	set_column_expand(ACTION_COLUMN_INDEX, false)
	set_column_expand(MIN_COLUMN_INDEX, false)
	set_column_expand(MAX_COLUMN_INDEX, false)
	set_column_custom_minimum_width(MIN_COLUMN_INDEX, 32)
	set_column_custom_minimum_width(MAX_COLUMN_INDEX, 32)
	
	var root = create_item()
	
	root.set_text(NAME_COLUMN_INDEX, scanned_files.name)
	root.set_editable(NAME_COLUMN_INDEX, false)
	root.set_metadata(NAME_COLUMN_INDEX, scanned_files)	
			
	for file in scanned_files.rules:
		var f = create_item(root)
		f.set_editable(NAME_COLUMN_INDEX, false)
		f.set_editable(MIN_COLUMN_INDEX, true)
		f.set_editable(MAX_COLUMN_INDEX, true)
		f.set_text(NAME_COLUMN_INDEX, file.name)
		f.set_text(MIN_COLUMN_INDEX, file.min)
		f.set_text(MAX_COLUMN_INDEX, file.max)
		f.add_button(ACTION_COLUMN_INDEX, load("res://assets/icons/white/minus_small.png"))
		f.set_metadata(ACTION_COLUMN_INDEX, "remove")
		f.set_metadata(NAME_COLUMN_INDEX, file)		
			
	if on_item_button_pressed not in self.button_clicked.get_connections().map(func(x): return x["callable"]):
		self.button_clicked.connect(on_item_button_pressed)
		
	new_rule_child = create_item(root)
	new_rule_child.set_editable(NAME_COLUMN_INDEX, false)
	new_rule_child.set_text(NAME_COLUMN_INDEX, "Add Step")
	new_rule_child.add_button(ACTION_COLUMN_INDEX, load("res://assets/icons/white/plus_small.png"))
	new_rule_child.set_metadata(ACTION_COLUMN_INDEX, "add")
	
	
	current_step = root.get_first_child()
	#file_tree.check_propagated_to_item.connect(prop)


func on_item_button_pressed(item: TreeItem, col, id, ind) -> void:
	var action = item.get_metadata(ACTION_COLUMN_INDEX)
	if action == "remove":
		var confirm = ConfirmationDialog.new()
		get_tree().root.add_child(confirm)
		confirm.confirmed.connect(remove_rule.bind(item, confirm))
		confirm.close_requested.connect((func(x): x.queue_free()))
		confirm.canceled.connect((func(x): x.queue_free()))
		confirm.move_to_center()
		confirm.show()
	elif action == "add":
		var load_rule_diag = FileDialog.new()
		get_tree().root.add_child(load_rule_diag)
		load_rule_diag.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		load_rule_diag.confirmed.connect(add_rule.bind(load_rule_diag))
		load_rule_diag.close_requested.connect((func(x): x.queue_free()))
		load_rule_diag.canceled.connect((func(x): x.queue_free()))
		load_rule_diag.move_to_center()
		load_rule_diag.root_subfolder = "rules"
		load_rule_diag.show()
		

func remove_rule(item: TreeItem, confirm) -> void:
	print("deleting file")
	item.free()
	confirm.queue_free()
	
func get_next() -> JsonItemFile:
	var to_return = current_step
	if current_step == null:
		return null
	current_step = current_step.get_next()
	
	return to_return.get_metadata(NAME_COLUMN_INDEX)
	
func add_rule(confirm) -> void:
	print("add ", confirm.current_path)
	var new_item = create_item(self.get_root())
	new_item.move_before(new_rule_child)
	new_item.set_editable(NAME_COLUMN_INDEX, false)
	new_item.set_editable(MIN_COLUMN_INDEX, true)
	new_item.set_editable(MAX_COLUMN_INDEX, true)
	new_item.set_text(NAME_COLUMN_INDEX, confirm.current_file.get_basename())
	new_item.add_button(ACTION_COLUMN_INDEX, load("res://assets/icons/white/minus_small.png"))
	new_item.set_metadata(ACTION_COLUMN_INDEX, "remove")
	new_item.set_metadata(NAME_COLUMN_INDEX, confirm.current_path)
	confirm.queue_free()
	
func get_recipe_rules(path: String) -> JsonItemDirectory:
	if not FileAccess.file_exists(path): return JsonItemDirectory.new()
	var file = FileAccess.open(path, FileAccess.READ)
	var rules = JsonItemDirectory.new()
	var line = file.get_line()
	rules.name = path.get_basename()
	rules.path = path
	while not file.eof_reached():
		var params = line.split(",") as PackedStringArray
		rules.rules.append(JsonItemFile.new(params.get(0), params.get(1), params.get(2), params.get(3)))
		line = file.get_line()
		
	return rules
	
	
class JsonItemDirectory:
	var name: String
	var path: String
	var rules : Array
	
	func to_data_dict() -> Dictionary:
		var dict = {
			"name" : self.name,
			"path" : self.path,
			"rules": self.files.map(func(x): return x.to_data_dict())
		}
		return dict
	
class JsonItemFile:
	var name: String
	var path: String
	var min: String
	var max: String
	
	func _init(file_name: String, dir: String, min: String, max: String) -> void:
		self.name = file_name
		self.path = dir
		self.min = min
		self.max = max
	
	func to_data_dict() -> Dictionary:
		var dict = {
			"name" : self.name,
			"path" : self.path,
			"min" : self.min,
			"max" : self.max,
		}
		return dict
