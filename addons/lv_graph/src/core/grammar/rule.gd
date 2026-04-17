class_name LVRule
extends Resource

var _pattern: LVGraph
var _output: LVGraph
	
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
	var text = file.get_as_text()
	#split text into input graph and output graph
	
	var pattern_text
	var output_text
	
	var rule = LVRule.new()
	rule._pattern = LVGraph.from_string(pattern_text)
	rule._output = LVGraph.from_string(output_text)
		
	return rule
