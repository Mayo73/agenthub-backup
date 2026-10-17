class_name FishStats
extends RefCounted
## Statistik der Fischphase: gefressene Fische je Art, Tode und größte erreichte Tiefe.

## Art-ID → Anzahl gefressener Fische
var eaten := {}
var deaths := 0
var max_depth := 0.0


func record_eaten(species_id: String) -> void:
	eaten[species_id] = int(eaten.get(species_id, 0)) + 1


func record_death() -> void:
	deaths += 1


func record_depth(depth: float) -> void:
	max_depth = maxf(max_depth, depth)


func total_eaten() -> int:
	var n := 0
	for id: String in eaten:
		n += int(eaten[id])
	return n


func to_dict() -> Dictionary:
	return {"eaten": eaten.duplicate(), "deaths": deaths, "max_depth": max_depth}


static func from_dict(data: Dictionary) -> FishStats:
	var s := FishStats.new()
	var e: Variant = data.get("eaten", {})
	if e is Dictionary:
		for id: String in e:
			s.eaten[id] = maxi(0, int(e[id]))
	s.deaths = maxi(0, int(data.get("deaths", 0)))
	s.max_depth = maxf(0.0, float(data.get("max_depth", 0.0)))
	return s


## Eine Zeile für Anzeigen, z. B. "Gefressen: 3 · Tode: 1 · Tiefste Stelle: 42 m".
func summary() -> String:
	return "Gefressen: %d · Tode: %d · Tiefste Stelle: %d m" % [total_eaten(), deaths, roundi(max_depth)]
