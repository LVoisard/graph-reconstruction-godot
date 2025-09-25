extends FileTree
class_name ManualFileTree
signal load_lsystem_rule(path)

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
		f.add_button(DELETE_FILE_COLUMN_INDEX, load("res://assets/icons/FileAccess.svg"))
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
		f.add_button(DELETE_FILE_COLUMN_INDEX, load("res://assets/icons/FileAccess.svg"))
		f.set_metadata(NAME_COLUMN_INDEX, file.path)
	
	if tree_item.get_children().is_empty():
		root.remove_child(tree_item)

func on_item_button_pressed(item: TreeItem, col, id, ind) -> void:
	var path = item.get_metadata(NAME_COLUMN_INDEX)
	if col == VIEW_FILE_COLUMN_INDEX:
		load_rule.emit(path)
	elif col == DELETE_FILE_COLUMN_INDEX:
		load_lsystem_rule.emit(path)
