class_name HitStats
extends RefCounted
## Zähle Schüsse, Treffer und berechne Genauigkeit je Waffe.

var _shots: Dictionary = {}
var _hits: Dictionary = {}


func shot(weapon: String) -> void:
	_shots[weapon] = _shots.get(weapon, 0) + 1


func hit(weapon: String) -> void:
	_hits[weapon] = _hits.get(weapon, 0) + 1


func shots(weapon: String = "") -> int:
	if weapon == "":
		var total: int = 0
		for count in _shots.values():
			total += count
		return total
	return _shots.get(weapon, 0)


func hits(weapon: String = "") -> int:
	if weapon == "":
		var total: int = 0
		for count in _hits.values():
			total += count
		return total
	return _hits.get(weapon, 0)


func accuracy(weapon: String = "") -> float:
	var shot_count: int = shots(weapon)
	if shot_count == 0:
		return 0.0
	return float(hits(weapon)) / float(shot_count)


func weapons() -> Array[String]:
	var weapon_dict: Dictionary = {}
	for weapon in _shots.keys():
		weapon_dict[weapon] = true
	for weapon in _hits.keys():
		weapon_dict[weapon] = true

	var sorted_weapons: Array[String] = []
	for weapon in weapon_dict.keys():
		sorted_weapons.append(weapon)
	sorted_weapons.sort()
	return sorted_weapons


func reset() -> void:
	_shots.clear()
	_hits.clear()


func to_dict() -> Dictionary:
	var shots_dict: Dictionary = {}
	for weapon in _shots:
		shots_dict[weapon] = _shots[weapon]

	var hits_dict: Dictionary = {}
	for weapon in _hits:
		hits_dict[weapon] = _hits[weapon]

	return {"shots": shots_dict, "hits": hits_dict}


static func from_dict(data: Dictionary) -> HitStats:
	var stats := HitStats.new()

	if data.has("shots"):
		var shots_data := data["shots"] as Dictionary
		for weapon in shots_data:
			stats._shots[weapon] = int(shots_data[weapon])

	if data.has("hits"):
		var hits_data := data["hits"] as Dictionary
		for weapon in hits_data:
			stats._hits[weapon] = int(hits_data[weapon])

	return stats
