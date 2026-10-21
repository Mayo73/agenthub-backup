class_name GridPath
extends RefCounted

## Breitensuche auf einem 2D-Raster. Nachbarreihenfolge: (1,0), (0,1), (-1,0), (0,-1).

var size: Vector2i = Vector2i.ZERO
var blocked: Dictionary = {}


func _init(grid_size: Vector2i = Vector2i.ZERO) -> void:
	size = grid_size


func set_blocked(cell: Vector2i, on: bool = true) -> void:
	if on:
		blocked[cell] = true
	else:
		blocked.erase(cell)


func is_free(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.x >= size.x or cell.y < 0 or cell.y >= size.y:
		return false
	return not blocked.has(cell)


func find_path(start: Vector2i, goal: Vector2i) -> Array:
	if not is_free(start) or not is_free(goal):
		return []
	if start == goal:
		return [start]

	const ORDER: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(0, 1),
		Vector2i(-1, 0),
		Vector2i(0, -1)
	]

	var queue: Array[Vector2i] = []
	queue.append(start)

	var came_from: Dictionary = {}
	came_from[start] = null

	while not queue.is_empty():
		var current: Vector2i = queue.pop_front()

		if current == goal:
			var path: Array[Vector2i] = []
			var cell: Vector2i = goal
			while cell != start:
				path.append(cell)
				cell = came_from[cell] as Vector2i
			path.append(start)
			path.reverse()
			return path

		for dir: Vector2i in ORDER:
			var neighbor: Vector2i = current + dir
			if not is_free(neighbor):
				continue
			if came_from.has(neighbor):
				continue
			came_from[neighbor] = current
			queue.append(neighbor)

	return []
