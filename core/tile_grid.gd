extends RefCounted
class_name TileGrid

## Größe einer Kachel in Metern
var cell_size: float = 1.0:
	set(value):
		cell_size = value

## Zellen als Dictionary (Schlüssel Vector2i → Kachelart als String)
var cells: Dictionary = {}


func _init(size: float = 1.0) -> void:
	cell_size = size


func set_cell(cell: Vector2i, kind: String) -> void:
	if kind == "":
		cells.erase(cell)
	else:
		cells[cell] = kind


func get_cell(cell: Vector2i) -> String:
	return cells.get(cell, "")


func world_to_cell(p: Vector2) -> Vector2i:
	return Vector2i(floori(p.x / cell_size), floori(p.y / cell_size))


func cell_to_world(cell: Vector2i) -> Vector2:
	var center_x: float = cell.x * cell_size + cell_size / 2.0
	var center_y: float = cell.y * cell_size + cell_size / 2.0
	return Vector2(center_x, center_y)


func fill_rect(from: Vector2i, to: Vector2i, kind: String) -> int:
	var min_x: int = min(from.x, to.x)
	var max_x: int = max(from.x, to.x)
	var min_y: int = min(from.y, to.y)
	var max_y: int = max(from.y, to.y)

	var count: int = 0
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var cell: Vector2i = Vector2i(x, y)
			if kind == "":
				cells.erase(cell)
			else:
				cells[cell] = kind
			count += 1

	return count


func count(kind: String) -> int:
	var c: int = 0
	for k in cells.keys():
		if cells[k] == kind:
			c += 1
	return c


func used_rect() -> Rect2i:
	if cells.is_empty():
		return Rect2i()

	var min_x: int = 999999999
	var max_x: int = -999999999
	var min_y: int = 999999999
	var max_y: int = -999999999

	for cell in cells.keys():
		min_x = min(min_x, cell.x)
		max_x = max(max_x, cell.x)
		min_y = min(min_y, cell.y)
		max_y = max(max_y, cell.y)

	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func to_dict() -> Dictionary:
	var result: Dictionary = {
		"cell_size": cell_size,
		"cells": []
	}

	var sorted_keys: Array = cells.keys().duplicate()
	sorted_keys.sort()

	for k in sorted_keys:
		result.cells.append("%d,%d,%s" % [k.x, k.y, cells[k]])

	return result


static func from_dict(d: Dictionary) -> TileGrid:
	var grid: TileGrid = TileGrid.new()
	grid.cell_size = float(d.get("cell_size", 1.0))

	var cell_data: Array = d.get("cells", [])
	for s in cell_data:
		var parts: PackedStringArray = s.split(",")
		if parts.size() >= 3:
			var x: int = int(parts[0])
			var y: int = int(parts[1])
			var kind: String = parts[2]
			grid.cells[Vector2i(x, y)] = kind

	return grid
