class_name HighscoreTable
extends RefCounted

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
