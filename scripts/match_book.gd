class_name MatchBook
extends RefCounted
## Verwaltet Interessen, Matches und Blocks zwischen Personen.

var likes: Dictionary = {}           # "<von>><an>" -> true
var passes: Dictionary = {}          # "<von>><an>" -> true
var blocks: Dictionary = {}          # "<von>><an>" -> true
var matches: Array[Dictionary] = []  # {"id": "m1", "a": "p01", "b": "p02", "ended_by": ""}
var next_id := 1

static func key(from_id: String, to_id: String) -> String:
	return from_id + ">" + to_id

func like(from_id: String, to_id: String) -> String:
	# Kein Like auf sich selbst
	if from_id == to_id:
		return ""
	# Nicht liken, wenn einer den anderen blockiert hat
	if is_blocked(from_id, to_id):
		return ""
	if is_blocked(to_id, from_id):
		return ""

	var k := key(from_id, to_id)
	likes[k] = true

	# Prüfen, ob gegenseitiges Interesse besteht und noch kein Match existiert
	var reverse_k := key(to_id, from_id)
	if likes.has(reverse_k) and match_between(from_id, to_id).is_empty():
		return _create_match(to_id, from_id)
	return ""

func _create_match(a: String, b: String) -> String:
	var m := {"id": "m%d" % next_id, "a": a, "b": b, "ended_by": ""}
	next_id += 1
	matches.append(m)
	return m["id"]

func pass_on(from_id: String, to_id: String) -> void:
	var k := key(from_id, to_id)
	passes[k] = true

func has_swiped(from_id: String, to_id: String) -> bool:
	return likes.has(key(from_id, to_id)) or passes.has(key(from_id, to_id))

func match_between(id1: String, id2: String) -> Dictionary:
	for m in matches:
		if m["a"] == id1 and m["b"] == id2:
			return m
		if m["a"] == id2 and m["b"] == id1:
			return m
	return {}

func get_match(match_id: String) -> Dictionary:
	for m in matches:
		if m["id"] == match_id:
			return m
	return {}

func matches_of(user_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for m in matches:
		if m["a"] == user_id or m["b"] == user_id:
			result.append(m)
	return result

func is_active(match_id: String) -> bool:
	var m := get_match(match_id)
	return not m.is_empty() and m["ended_by"] == ""

func end_match(match_id: String, by_id: String) -> void:
	var m := get_match(match_id)
	if m.is_empty():
		return
	if m["ended_by"] != "":
		return  # Bereits beendet
	if m["a"] != by_id and m["b"] != by_id:
		return  # Nutzer nicht beteiligt
	m["ended_by"] = by_id

func other(m: Dictionary, user_id: String) -> String:
	if m.is_empty():
		return ""
	if m.get("a") == user_id:
		return m.get("b", "")
	if m.get("b") == user_id:
		return m.get("a", "")
	return ""

func is_blocked(id1: String, id2: String) -> bool:
	return blocks.has(key(id1, id2)) or blocks.has(key(id2, id1))

func block(from_id: String, to_id: String) -> void:
	var k := key(from_id, to_id)
	blocks[k] = true
	# Aktives Match zwischen beiden beenden
	for m in matches:
		if (m["a"] == from_id and m["b"] == to_id) or (m["a"] == to_id and m["b"] == from_id):
			if m["ended_by"] == "":
				m["ended_by"] = from_id

func candidates(user_id: String, all_ids: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for id in all_ids:
		if id == user_id:
			continue
		if has_swiped(user_id, id):
			continue
		if is_blocked(user_id, id):
			continue
		if is_blocked(id, user_id):
			continue
		if not match_between(user_id, id).is_empty():
			continue
		result.append(id)
	return result

func to_dict() -> Dictionary:
	return {
		"likes": likes,
		"passes": passes,
		"blocks": blocks,
		"matches": matches,
		"next_id": next_id
	}

static func from_dict(d: Dictionary) -> MatchBook:
	var book := MatchBook.new()
	book.likes = d.get("likes", {}).duplicate(true)
	book.passes = d.get("passes", {}).duplicate(true)
	book.blocks = d.get("blocks", {}).duplicate(true)
	book.matches.assign(d.get("matches", []).duplicate(true))
	book.next_id = int(d.get("next_id", 1))
	return book
