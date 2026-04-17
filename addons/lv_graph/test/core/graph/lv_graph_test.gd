# GdUnit generated TestSuite
class_name LvGraphTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://addons/lv_graph/src/core/graph/lv_graph.gd'

var graph: LVGraph

func before_test() -> void:
	graph = LVGraph.new()

func test_create_node() -> void:	
	var node: LVNode = graph.create_node()
	
	assert_int(node.id).is_equal(0)
	assert_int(graph.get_nodes().size()).is_equal(1)

func test_remove_node() -> void:
	var node: LVNode = graph.create_node()
	
	assert_int(node.id).is_equal(0)
	assert_int(graph.get_nodes().size()).is_equal(1) 
	
	graph.remove_node(node.id)

func test_connect_nodes() -> void:
	var node1: LVNode = graph.create_node()
	var node2: LVNode = graph.create_node()
	
	graph.connect_nodes(node1.id, node2.id)
	
	assert_int(graph.get_nodes().size()).is_equal(2) 
	assert_int(graph._edges.size()).is_equal(1)
	assert_int(graph._edges[0].from).is_equal(0) 
	assert_int(graph._edges[0].to).is_equal(1) 
	
