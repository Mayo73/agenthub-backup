class_name RecentProjects
extends RefCounted

var paths: Array[String] = []
var limit := 5


func _init(max_count: int = 5) -> void:
	limit = max_count


func _normalize_path(path: String) -> String:
	return path.replace("\\", "/")


func add(path: String) -> void:
	var normalized := _normalize_path(path)
	for i in range(paths.size()):
		if paths[i].to_lower() == normalized.to_lower():
			paths.remove_at(i)
			break
	paths.insert(0, normalized)
	while paths.size() > limit:
		paths.pop_back()


func remove(path: String) -> void:
	var normalized := _normalize_path(path)
	for i in range(paths.size()):
		if paths[i].to_lower() == normalized.to_lower():
			paths.remove_at(i)
			break


func to_dict() -> Dictionary:
	return {"paths": paths.duplicate(), "limit": limit}


static func from_dict(d: Dictionary) -> RecentProjects:
	var result: RecentProjects = RecentProjects.new()
	result.limit = int(d.get("limit", 5))
	var path_array: Array[String] = d.get("paths", [])
	for i in range(path_array.size() - 1, -1, -1):
		var item = path_array[i]
		if item is String:
			result.add(item)
	return result
