extends Node2D

var room_prefab: PackedScene = preload("res://scenes/dungeon_room.tscn")

@onready var generator: Generator = $"Generator" 

func _ready():
	var done = false
	
	var map: Map
	var graph: GodotGraph
	while !done:
		graph =	(await generator.generate_dungeon_graph("res://recipes/test.txt")).backend
		#graph.AssignAccessLevels()
		
		var layout = LayoutHandler.new()
		
		
		for i in range(100):
			map = layout.GenerateDungeon(graph) as Map
			if map != null: break;
			
		if map != null:
			done = true
		else:
			print("generation failed")
	
	
			
	#	print(cell.x)
	for cell in map.get2DMap():
		if cell != null:
			cell.node.SetPosition(cell.x * 150, cell.y * 150)
			print(cell.x, cell.y)
	generator.update_graph_visual()

	var extent = compute_extent(graph, 20, 1)
	
	$WFC2DGenerator.rect.position = extent.position
	$WFC2DGenerator.rect.size = extent.size
	
	for x in range(0,$WFC2DGenerator.rect.size.x):
			for y in range(0,$WFC2DGenerator.rect.size.y):
				$target/main.set_cell($WFC2DGenerator.rect.position + Vector2i(x,y), 0, Vector2i(0,0))
	
	for cell in map.get2DMap():
		if cell != null:
			var base_pos = (Vector2i(cell.x * 20, cell.y * 20))
			if cell.node.Type == 7: continue
			
			for x in range(0,21):
				for y in range(0,21):
					$target/main.set_cell(base_pos - Vector2i(2,2) + Vector2i(x,y), 0, Vector2i(0,0))
				
			for x in range(0,17):
				for y in range(0,17):
					$target/main.set_cell(base_pos + Vector2i(x,y), 0, Vector2i(0,4))
			
			# temp to visualize the node type
			$target/main.set_cell(base_pos + Vector2i(8,8), 0, Vector2i(cell.node.Type,0))
	
	
	for cell in map.get2DMap():
		if cell == null: continue
		var me = cell.node
		for x in range(0,3):
			for y in range (0,3):
				var doorDir = Vector2i(x-1, y-1)
				if abs(doorDir.x) == abs(doorDir.y) : continue
				print(doorDir)
				
				var door = cell.getDoor(doorDir.x, doorDir.y)
				print(door)
				if door == 1: # opened
					$target/main.set_cell(Vector2i(cell.x * 20, cell.y * 20) - doorDir * Vector2i(9,9) +  Vector2i(8,8), 0, Vector2i(0,4))
					$target/main.set_cell(Vector2i(cell.x * 20, cell.y * 20)  - doorDir * Vector2i(10,10) +  Vector2i(8,8), 0, Vector2i(0,4))
					
				elif door == 2: # locked
					$target/decorations.set_cell(Vector2i(cell.x * 20, cell.y * 20)  - doorDir * Vector2i(9,9) +  Vector2i(8,8), 0, Vector2i(10,5))
					$target/decorations.set_cell(Vector2i(cell.x * 20, cell.y * 20)  - doorDir * Vector2i(10,10) +  Vector2i(8,8), 0, Vector2i(10,5))
				
	#for con in graph.GetEdges():
		#if con.Type != 0: continue
		#var grid_path_nodes =thicken_line_voxels(bresenham_line_3d(Vector2i(con.From.X, con.From.Y)/7 + Vector2i(8,8), Vector2i(con.To.X, con.To.Y)/7 + Vector2i(8,8)) , 3)
		#for pos in grid_path_nodes:
			#$target/main.set_cell(pos, 0, Vector2i(0,4))
		#var room = room_prefab.instantiate() as DungeonRoom
		#room.translate(Vector2i(vert.X, vert.Y) / 2)
		#room.setup_room(graph, vert)
		#add_child(room)
	$sample.hide()
	$target.show()
	$remap_classes.hide()
	$negative_sample.hide()
	#$WFC2DGenerator.start()
	



func compute_extent(graph, offset, scale) -> Rect2i:
	if graph.GetVertices().is_empty():
		return Rect2i()

	var verts = graph.GetVertices()
	var minx = (verts[0].X) - offset
	var miny = (verts[0].Y) - offset
	var maxx = (verts[0].X) + offset
	var maxy = (verts[0].Y) + offset

	for i in range(1, verts.size()):
		var v = verts[i]
		minx = min(minx, (v.X - offset))
		miny = min(miny, (v.Y - offset))
		maxx = max(maxx, (v.X + offset))
		maxy = max(maxy, (v.Y + offset))

	return Rect2i(minx / scale, miny / scale, (maxx - minx) /  scale + 16, (maxy - miny) /  scale + 16)


func bresenham_line_3d(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	
	var x0 = a.x
	var y0 = a.y
	var x1 = b.x
	var y1 = b.y

	var dx = abs(x1 - x0)
	var dy = abs(y1 - y0)

	var sx = 1 if x0 < x1 else -1
	var sy = 1 if y0 < y1 else -1

	var dx2 = dx * 2
	var dy2 = dy * 2

	var err1: int
	var err2: int

	if dx >= dy:
		err1 = dy2 - dx
		while x0 != x1:
			points.append(Vector2i(x0, y0))
			if err1 > 0:
				y0 += sy
				err1 -= dx2
			err1 += dy2
			x0 += sx
	elif dy >= dx:
		err1 = dx2 - dy
		while y0 != y1:
			points.append(Vector2i(x0, y0))
			if err1 > 0:
				x0 += sx
				err1 -= dy2
			err1 += dx2
			y0 += sy

	points.append(Vector2i(x1, y1))  # add final point
	return points


func thicken_line_voxels(line_voxels: Array[Vector2i], thickness: int) -> Array:
	var thick_voxels = {}
	var r = thickness

	for voxel in line_voxels:
		for dx in range(-r, r + 1):
			for dy in range(-r, r + 1):
				var p = voxel + Vector2i(dx, dy)
				thick_voxels[p] = true  # using a dictionary to prevent duplicates

	return thick_voxels.keys()
