class_name SparFilter
extends RefCounted

## Filterkriterien für Testprofile
var art := ""
var level := -1


## Prüfen, ob Profil p die Filterkriterien erfüllt
func matches(p: SparProfile) -> bool:
	# Sportart-Filter (wenn gesetzt)
	if art != "" and p.art != art:
		return false

	# Level-Filter (wenn gesetzt)
	if level != -1 and p.level != level:
		return false

	return true


## Alle Profile zurückgeben, die den Filterkriterien entsprechen
func apply(profiles: Array[SparProfile]) -> Array[SparProfile]:
	var result: Array[SparProfile] = []
	for p in profiles:
		if matches(p):
			result.append(p)
	return result


## Prüfen, ob Filter aktiv ist (mindestens eine Bedingung gesetzt)
func is_active() -> bool:
	return art != "" or level != -1


## Filter zurücksetzen auf "alle Werte"
func clear() -> void:
	art = ""
	level = -1


## Beschreibenden String für den aktuellen Filter zurückgeben
func describe() -> String:
	var parts: Array[String] = []

	if art != "":
		parts.append(art)

	if level != -1:
		parts.append(SparProfile.LEVELS[level])

	if parts.is_empty():
		return "Alle Testprofile"

	return " · ".join(parts)


## Filter als Dictionary serialisieren
func to_dict() -> Dictionary:
	return {
		"art": art,
		"level": level
	}


## Filter aus Dictionary deserialisieren
static func from_dict(d: Dictionary) -> SparFilter:
	var filter := SparFilter.new()

	filter.art = d.get("art", "")
	filter.level = int(d.get("level", -1))

	return filter
