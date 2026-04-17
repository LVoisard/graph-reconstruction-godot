class_name LVSubgraphIsomorphism
extends Object


static func is_isomorphic(target: LVGraph, pattern: LVGraph) -> bool:
	return _backtrack_first_recv(target, pattern, {}, {}, 0)

static func find_first(target: LVGraph, pattern: LVGraph) -> Dictionary:
	var mapping: Dictionary = {}
	var usedTargetVertices: Dictionary = {}
	
	_backtrack_first_recv(target, pattern, mapping, usedTargetVertices, 0)
	return mapping


static func _backtrack_first_recv(target: LVGraph, pattern: LVGraph, mapping: Dictionary, usedTargetVertices: Dictionary, patternIndex: int) -> bool:
	
	if patternIndex == pattern._nodes.size():
		return true
	
	var patternNode = pattern.get_node(patternIndex)
	
	for candidate_id in target.get_nodes():
		if usedTargetVertices.find_key(candidate_id):
			continue
		
		if isValidMapping():
			mapping[patternNode] = pattern.get_node(candidate_id)
			usedTargetVertices[candidate_id] = null
			
			if _backtrack_first_recv(target, pattern, mapping, usedTargetVertices, pattern.get_next_node_id(patternIndex)):
				return true
				
			mapping.erase(patternNode)
			usedTargetVertices.erase(candidate_id)
	return false
	
static func isValidMapping() -> bool:
	return true
	
	
static func apply_rewrite(target: LVGraph, rewrite: LVGraph):
	pass
