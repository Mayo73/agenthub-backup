class_name HighscoreTable
extends RefCounted

const DEFAULT_PATH := "user://bestenliste.json"

var entries: Dictionary = {}


func best_time(track_id: String) -> float:
	if not entries.has(track_id):
		return -1.0
	return entries[track_id].time


func best_points(track_id: String) -> int:
	if not entries.has(track_id):
		return 0
	return int(entries[track_id].points)


func submit(track_id: String, time: float, points: int) -> Dictionary:
	var new_time: bool = false
	var new_points: bool = false

	if not entries.has(track_id):
		entries[track_id] = {"time": -1.0, "points": 0}

	if time > 0.0 and (best_time(track_id) < 0.0 or time < best_time(track_id)):
		new_time = true
		entries[track_id].time = time

	if points > best_points(track_id):
		new_points = true
		entries[track_id].points = points

	return {"new_time": new_time, "new_points": new_points}


func save(path: String = DEFAULT_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(entries))
	file.close()
	return true


static func load_from(path: String = DEFAULT_PATH) -> HighscoreTable:
	var table := HighscoreTable.new()
	if not FileAccess.file_exists(path):
		return table
	var text := FileAccess.get_file_as_string(path)
	if text == null:
		return table
	var json := JSON.new()
	var error := json.parse(text)
	if error != OK:
		return table
	var result: Variant = json.data
	if not typeof(result) == TYPE_DICTIONARY:
		return table
	for key in result.keys():
		var e: Dictionary = result[key]
		if typeof(e) == TYPE_DICTIONARY:
			table.entries[key] = {"time": float(e.get("time", -1.0)), "points": int(e.get("points", 0))}
	return table
