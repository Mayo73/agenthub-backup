class_name ScoreBoard
extends RefCounted
## Bestenliste für Referenzspiele mit begrenzter Länge und JSON-Support.

var max_entries: int = 10
var entries: Array = []


func qualifies(score: int) -> bool:
	if entries.size() < max_entries:
		return true
	var last: Dictionary = entries[entries.size() - 1]
	var lowest: int = int(last["score"])
	return score > lowest


func add(name: String, score: int) -> int:
	if not qualifies(score):
		return 0

	var insert_pos := 0
	while insert_pos < entries.size():
		var e: Dictionary = entries[insert_pos]
		var s: int = int(e["score"])
		if score < s:
			insert_pos += 1
		elif score == s:
			insert_pos += 1
		else:
			break

	entries.insert(insert_pos, {"name": name, "score": score})

	while entries.size() > max_entries:
		entries.pop_back()

	return insert_pos + 1


func best() -> int:
	if entries.is_empty():
		return 0
	var first: Dictionary = entries[0]
	return int(first["score"])


func lines() -> Array[String]:
	var result: Array[String] = []
	for i in range(entries.size()):
		var e: Dictionary = entries[i]
		var name: String = e["name"]
		var s: int = int(e["score"])
		result.append("%d. %s – %d" % [i + 1, name, s])
	return result


func to_dict() -> Dictionary:
	var entry_dicts: Array[Dictionary] = []
	for e in entries:
		entry_dicts.append({"name": e["name"], "score": e["score"]})
	return {"max_entries": max_entries, "entries": entry_dicts}


static func from_dict(d: Dictionary) -> ScoreBoard:
	var board: ScoreBoard = ScoreBoard.new()
	board.max_entries = int(d.get("max_entries", 10))
	var entry_data: Array = d.get("entries", [])
	for e in entry_data:
		var entry: Dictionary = {"name": str(e["name"]), "score": int(e["score"])}
		board.entries.append(entry)
	return board
