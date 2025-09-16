extends Node3D

@onready var generator: Generator = $"Generator"
@onready var grid_map: GridMap = $"GridMap"

var player_prefab: PackedScene = preload("res://addons/basic_fps_player.tscn")

func _ready() -> void:
	var cs_class = load("res://scripts/TestCSharp.cs")
	cs_class.Test()
	var graph = await generator.generate_dungeon_graph("res://recipes/test.txt")

	var room_positions = {}
	for node in graph.nodes:
		var room_pos = Vector3i(node.position.x / 2, 0, node.position.y / 2)
		room_positions[node] = room_pos
	
	for con in graph.connections:
		if con.connection_type == Connection.ConnectionType.Relational: continue
		var grid_path_nodes =thicken_line_voxels(bresenham_line_3d(room_positions[con.a()], room_positions[con.b()]), 3)
		for pos in grid_path_nodes:
			grid_map.set_cell_item(pos, grid_map.mesh_library.find_item_by_name("floor-small-square"))
		#for x in max(1, ab.x):
		#	for z in max(1, ab.z):
		#		grid_map.set_cell_item(room_positions[con.a()] + Vector3i(x, 0, z), grid_map.mesh_library.find_item_by_name("floor-square"))	

	for node in graph.nodes:
		for i in range(-10, 10):
			for j in range(-10, 10):
				grid_map.set_cell_item(room_positions[node] + Vector3i(i, 0, j), grid_map.mesh_library.find_item_by_name("floor-square"))
				
	var player = player_prefab.instantiate()
	add_child(player)
	player.position = room_positions[graph.get_entrance_node()] + Vector3i(0,5,0)

func graph_has_edge_overlap(graph: VisualGraph) -> bool:
	var used_voxels := {}
	
	

	return false  # No overlaps found

func bresenham_line_3d(a: Vector3i, b: Vector3i) -> Array[Vector3i]:
	var points: Array[Vector3i] = []
	
	var x0 = a.x
	var y0 = a.y
	var z0 = a.z
	var x1 = b.x
	var y1 = b.y
	var z1 = b.z

	var dx = abs(x1 - x0)
	var dy = abs(y1 - y0)
	var dz = abs(z1 - z0)

	var sx = 1 if x0 < x1 else -1
	var sy = 1 if y0 < y1 else -1
	var sz = 1 if z0 < z1 else -1

	var dx2 = dx * 2
	var dy2 = dy * 2
	var dz2 = dz * 2

	var err1: int
	var err2: int

	if dx >= dy and dx >= dz:
		err1 = dy2 - dx
		err2 = dz2 - dx
		while x0 != x1:
			points.append(Vector3i(x0, y0, z0))
			if err1 > 0:
				y0 += sy
				err1 -= dx2
			if err2 > 0:
				z0 += sz
				err2 -= dx2
			err1 += dy2
			err2 += dz2
			x0 += sx
	elif dy >= dx and dy >= dz:
		err1 = dx2 - dy
		err2 = dz2 - dy
		while y0 != y1:
			points.append(Vector3i(x0, y0, z0))
			if err1 > 0:
				x0 += sx
				err1 -= dy2
			if err2 > 0:
				z0 += sz
				err2 -= dy2
			err1 += dx2
			err2 += dz2
			y0 += sy
	else:
		err1 = dy2 - dz
		err2 = dx2 - dz
		while z0 != z1:
			points.append(Vector3i(x0, y0, z0))
			if err1 > 0:
				y0 += sy
				err1 -= dz2
			if err2 > 0:
				x0 += sx
				err2 -= dz2
			err1 += dy2
			err2 += dx2
			z0 += sz

	points.append(Vector3i(x1, y1, z1))  # add final point
	return points


func thicken_line_voxels(line_voxels: Array[Vector3i], thickness: int) -> Array:
	var thick_voxels = {}
	var r = thickness

	for voxel in line_voxels:
		for dx in range(-r, r + 1):
			for dz in range(-r, r + 1):
				var p = voxel + Vector3i(dx, 0, dz)
				thick_voxels[p] = true  # using a dictionary to prevent duplicates

	return thick_voxels.keys()
