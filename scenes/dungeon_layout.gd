extends Node2D

var room_prefab: PackedScene = preload("res://scenes/dungeon_room.tscn")

@onready var generator: Generator = $"Generator" 

func _ready():
	
	var graph: GodotGraph =	generator.generate_dungeon_graph("res://recipes/short.txt").backend
	var extent = compute_extent(graph)
	extent.size /= 3
	
	$WFC2DGenerator.rect = extent
	
	for x in range(0,$WFC2DGenerator.rect.size.x):
			for y in range(0,$WFC2DGenerator.rect.size.y):
				$target/main.set_cell($WFC2DGenerator.rect.position + Vector2i(x,y), 0, Vector2i(0,0))
	
	for vert in graph.GetVertices():
		var base_pos = Vector2i(vert.X, vert.Y) / 3 
		
			
		for x in range(0,16):
			for y in range(0,16):
				$target/main.set_cell(base_pos + Vector2i(x - 8,y - 8), 0, Vector2i(0,4))
		
		#var room = room_prefab.instantiate() as DungeonRoom
		#room.translate(Vector2i(vert.X, vert.Y) / 2)
		#room.setup_room(graph, vert)
		#add_child(room)
	$sample.hide()
	$target.show()
	$remap_classes.hide()
	$negative_sample.hide()
	$WFC2DGenerator.start()
	
	


func compute_extent(graph) -> Rect2i:
	if graph.GetVertices().is_empty():
		return Rect2i()

	var verts = graph.GetVertices()
	var minx = (verts[0].X - 8)
	var miny = (verts[0].Y - 8)
	var maxx = (verts[0].X + 8)
	var maxy = (verts[0].Y + 8)

	for i in range(1, verts.size()):
		var v = verts[i]
		minx = min(minx, (v.X - 8))
		miny = min(miny, (v.Y - 8))
		maxx = max(maxx, (v.X + 8))
		maxy = max(maxy, (v.Y + 8))

	return Rect2i(minx, miny, maxx - minx, maxy - miny)
