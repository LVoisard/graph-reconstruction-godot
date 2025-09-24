extends Node2D
class_name DungeonRoom

func setup_room(graph: GodotGraph, vert) -> void:
	print("setting up")
	
	$WFC2DGenerator.rect = Rect2i(position - Vector2(20,20) / 2, Vector2i(20,20))
	
	for x in range(0,20):
		for y in range(0,20):
			$target/main.set_cell(position + Vector2(x - 10,y - 10), 0, Vector2i(0,0))
			
	var base_pos = Vector2i(vert.X, vert.Y) / 2
	for x in range(0,16):
		for y in range(0,16):
			$target/main.set_cell(base_pos + Vector2i(x - 8,y - 8), 0, Vector2i(0,4))
			
	
	$sample.hide()
	$target.show()
	$remap_classes.hide()
	$negative_sample.hide()
	$WFC2DGenerator.start()
	
	
