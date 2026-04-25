class_name LVRule
extends Resource

var _pattern: LVGraph
var _output: LVGraph

func _init(pattern: LVGraph, output: LVGraph):
	self._pattern = pattern
	self._output = output
	
func apply(target_graph: LVGraph, mode: RuleMatchingMode) -> bool:
	
	#find subgraph
	var mapping
	match mode:
		RuleMatchingMode.FIRST: 
			mapping = LVSubgraphIsomorphism.find_first(target_graph, _pattern)			
		RuleMatchingMode.RANDOM: 
			mapping = LVSubgraphIsomorphism.find_first(target_graph, _pattern) # find all + pick random
		RuleMatchingMode.ALL:
			mapping = LVSubgraphIsomorphism.find_first(target_graph, _pattern) # find all
	if mapping.is_empty(): return false
	
	#Apply Rewrite
	
	return true

enum RuleMatchingMode {
	FIRST,
	RANDOM,
	ALL,
}


static func from_file(file: FileAccess) -> LVRule:
	print(file.get_as_text())
	
	var input_output: Array[String] = Helper.split_input_output(file)
		
	var pattern = LVGraph.from_string(input_output[0])
	var output = LVGraph.from_string(input_output[0])
	
	return LVRule.new(pattern, output)
