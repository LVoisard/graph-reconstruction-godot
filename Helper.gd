extends Node


func split_input_output(path: String) -> Array[String]:
	var file = FileAccess.open(path, FileAccess.READ)
	var input = ""
	var output = ""
	var mode = 0
	while not file.eof_reached():
		var line = file.get_line()
		if line == "": continue
		if line.contains("output"):
			mode = 1
		if line.contains("input") or line.contains("output") or line.contains("nodes") or line.contains("edges"): continue		
		
		if mode == 0:
			input += line
		else:
			output += line
	return [input, output]
	
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
