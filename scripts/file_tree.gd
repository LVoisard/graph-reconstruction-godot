class_name FileTree extends Tree

signal load_rule(path)

const NAME_COLUMN_INDEX = 0
const VIEW_FILE_COLUMN_INDEX = 1
const DELETE_FILE_COLUMN_INDEX = 2

func build_tree() -> void:
	clear()
	var scanned_files = get_all_files("res://rules/")
	
	set_column_title(NAME_COLUMN_INDEX, "Name")
	set_column_expand(VIEW_FILE_COLUMN_INDEX, false)
	set_column_expand(DELETE_FILE_COLUMN_INDEX, false)
	
	var root = create_item()
	root.set_icon(NAME_COLUMN_INDEX, load("res://assets/icons/Folder.svg"))
	root.set_text(NAME_COLUMN_INDEX, scanned_files.name)
	root.set_editable(NAME_COLUMN_INDEX, false)
	root.set_metadata(NAME_COLUMN_INDEX, scanned_files)
	
	

	for child in scanned_files.children:
		if child.files.size() == 0 && child.children.size() == 0: continue
		create_sub_tree(root, child)
		
	for file in scanned_files.files:
		var f = create_item(root)
		f.set_editable(NAME_COLUMN_INDEX, false)
		
		f.set_text(NAME_COLUMN_INDEX, file.name)
		f.set_icon(NAME_COLUMN_INDEX, load("res://assets/icons/File.svg"))
		f.add_button(VIEW_FILE_COLUMN_INDEX, load("res://assets/icons/FileAccess.svg"))
		f.add_button(DELETE_FILE_COLUMN_INDEX, load("res://assets/icons/Eraser.svg"))
		f.set_metadata(NAME_COLUMN_INDEX, file.path)
		
			
	if on_item_button_pressed not in self.button_clicked.get_connections().map(func(x): return x["callable"]):
		self.button_clicked.connect(on_item_button_pressed)
	
	#file_tree.check_propagated_to_item.connect(prop)

func create_sub_tree(root: TreeItem, item) -> void:
	
	var tree_item = create_item(root)
	tree_item.set_collapsed_recursive(true)
	tree_item.set_editable(NAME_COLUMN_INDEX, false)
	
	tree_item.set_icon(NAME_COLUMN_INDEX, load("res://assets/icons/Folder.svg"))
	tree_item.set_metadata(NAME_COLUMN_INDEX, item)
	tree_item.set_text(NAME_COLUMN_INDEX, item.name)	

	for child in item.children:
		if child.files.size() == 0 && child.children.size() == 0: continue
		create_sub_tree(tree_item, child)
	
	for file in item.files:
		var f = create_item(tree_item)
		f.set_editable(NAME_COLUMN_INDEX, false)
		f.set_text(NAME_COLUMN_INDEX, file.name)
		f.set_icon(NAME_COLUMN_INDEX, load("res://assets/icons/File.svg"))
		f.add_button(VIEW_FILE_COLUMN_INDEX, load("res://assets/icons/FileAccess.svg"))
		f.add_button(DELETE_FILE_COLUMN_INDEX, load("res://assets/icons/Eraser.svg"))
		f.set_metadata(NAME_COLUMN_INDEX, file.path)
	
	if tree_item.get_children().is_empty():
		root.remove_child(tree_item)

func on_item_button_pressed(item: TreeItem, col, id, ind) -> void:
	var path = item.get_metadata(NAME_COLUMN_INDEX)
	if col == VIEW_FILE_COLUMN_INDEX:
		load_rule.emit(path)
	elif col == DELETE_FILE_COLUMN_INDEX:
		var confirm = ConfirmationDialog.new()
		get_tree().root.add_child(confirm)
		confirm.confirmed.connect(delete_rule.bind(item, path, confirm))
		confirm.close_requested.connect((func(x): x.queue_free()).bind(confirm))
		confirm.canceled.connect((func(x): x.queue_free()).bind(confirm))
		confirm.move_to_center()
		confirm.show()
		

func delete_rule(item: TreeItem, path: String, confirm) -> void:
	print("deleting file")
	DirAccess.remove_absolute(path)
	item.free()
	confirm.queue_free()
	

func get_all_files(path: String, file_ext:= ["txt"]) -> JsonItemDirectory:
	var dir = DirAccess.open(path)
	
	var files = JsonItemDirectory.new()
	
	files.name = dir.get_current_dir().split("/")[-1]
	files.files = []
	files.children = []
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			var p = dir.get_current_dir(false) + "/" + file_name
			files.children.append(get_all_files(p, file_ext))
		else:
			var ext = file_name.get_extension()
			if !file_ext.is_empty() and ext not in file_ext:
				file_name = dir.get_next()
				continue
				
			var existing_file = files.files.filter(func(x: JsonItemFile): return x.name == file_name.get_basename())
			if existing_file.size() == 1:
				file_name = dir.get_next()
				continue
				
			files.files.append(JsonItemFile.new(file_name, dir, file_ext))
		file_name = dir.get_next()		
		#print(files.files.map(func(x): return x.name))
		files.files.sort_custom(func(a,b): return a.name < b.name)
		#print(files.files.map(func(x): return x.name))
	return files
	
class JsonItemDirectory:
	var name: String
	var children: Array
	var files : Array
	
	func to_data_dict() -> Dictionary:
		var dict = {
			"name" : self.name,
			"children" : self.children.map(func(x): return x.to_data_dict()),
			"files": self.files.map(func(x): return x.to_data_dict())
		}
		return dict
	
class JsonItemFile:
	var name: String
	var path: String	
	
	func _init(file_name: String, dir: DirAccess, file_ext: Array) -> void:		
		var base_file_path = dir.get_current_dir(false).path_join(file_name)
		self.name = file_name
		self.path = base_file_path
	
	func to_data_dict() -> Dictionary:
		var dict = {
			"name" : self.name,
			"path" : self.path			
		}
		return dict
