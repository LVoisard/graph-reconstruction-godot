extends Control

@onready var load_file_dialog: FileDialog = $"Load Recipe"
@onready var save_file_dialog: FileDialog = $"Save Recipe"

@onready var recipe_tree: RecipeTree = $"VBoxContainer/Recipe Menu/Tree"

func _ready() -> void:
	load_file_dialog.confirmed.connect(load_recipe)
	save_file_dialog.confirmed.connect(save_recipe)
	recipe_tree.build_tree("")
	

func save_recipe() -> void:
	var recipe: Array[Array] = []
	var root = recipe_tree.get_root()
	var current = root.get_first_child() as TreeItem
	while current != null:
		if current.get_text(recipe_tree.NAME_COLUMN_INDEX) != "Add Step":
			recipe.append([
				current.get_text(recipe_tree.NAME_COLUMN_INDEX),
				current.get_metadata(recipe_tree.NAME_COLUMN_INDEX),
				current.get_text(recipe_tree.MIN_COLUMN_INDEX),
				current.get_text(recipe_tree.MAX_COLUMN_INDEX)
				])
		current = current.get_next()
		
	var file = FileAccess.open(save_file_dialog.current_path, FileAccess.WRITE)
	for item in recipe:
		file.store_line(item.reduce(func(a,b): return str(a, ",", b)))	
	file.flush()
	file.close()
	print("save", save_file_dialog.current_path)

func load_recipe() -> void:
	recipe_tree.build_tree(load_file_dialog.current_path)
	print("load", load_file_dialog.current_path)
