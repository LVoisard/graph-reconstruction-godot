extends Node

func parse_graphs(path: String) -> Array[Dictionary]:
	var file = FileAccess.open(path, FileAccess.READ)
	var graphs: Array[Dictionary] = [
		{"nodes": [], "edges": []}, 
		{"nodes": [], "edges": []}
		]
	var index: int = 0
	var type: String = "nodes"
	while not file.eof_reached():
		var line = file.get_line()
		if line == "": continue
		if line.contains("edges"):
			type = "edges"
		if line.contains("output"):
			index = 1
			type = "nodes"
		if line.contains("input") or line.contains("output") or line.contains("nodes") or line.contains("edges"): continue		
		graphs[index][type].append(line)
	return graphs
