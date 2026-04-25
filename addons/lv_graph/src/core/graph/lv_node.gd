class_name LVNode
extends Resource

var _id: int
var _metadata: Dictionary[String, NodeMetadata]

func _init(id: int):
	_id = id

func get_id() -> int:
	return _id

func set_metadata(key: String, data) -> void:
	if not _metadata.has(key):
		_metadata[key] = NodeMetadata.new()
	_metadata[key]._data = data
	
func get_metadata(key: String) -> Variant:
	if not _metadata.has(key):
		print("no metadata for key %s", key)
	return _metadata[key]._data

class NodeMetadata:
	var _data
