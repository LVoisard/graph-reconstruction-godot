class_name Recipes extends Control

signal apply_rule_random(file_name)
signal apply_rule_lsystem(file_name)

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
				current.get_metadata(recipe_tree.NAME_COLUMN_INDEX).path,
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
	
func iterate_recipe() -> void:
	var step = recipe_tree.get_next()
	if step == null:
		print("Finished recipe")
		return
	await process_step(step)
		
func complete_recipe() -> void:
	var step = recipe_tree.get_next()
	while step != null:
		await process_step(step)
		step = recipe_tree.get_next()
		
func process_step(step) -> void:
	print("processing ", step.name)
	if int(step.min) == -1 and int(step.max) == -1:
		apply_rule_lsystem.emit(step.path.get_file())
	else:	
		for i in range(0, randi_range(int(step.min), int(step.max))):
			print(i + 1)
			apply_rule_random.emit(step.path.get_file())
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
