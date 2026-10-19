class_name InputSequence
extends RefCounted

## Halte-Einträge: je ein Dictionary {"action": String, "from": int, "to": int}
var holds: Array[Dictionary] = []

## Eine Taste für den Bereich [from_step, to_step) drücken
func hold(action: String, from_step: int, to_step: int) -> void:
	if to_step <= from_step:
		return
	var entry: Dictionary = {
		"action": action,
		"from": from_step,
		"to": to_step
	}
	holds.append(entry)

## Taste für genau einen Schritt drücken (von step bis step+1)
func tap(action: String, step: int) -> void:
	hold(action, step, step + 1)

## Prüfen, ob action bei einem bestimmten Schritt gedrückt ist
func is_pressed(action: String, step: int) -> bool:
	for entry in holds:
		var f: int = entry["from"]
		var t: int = entry["to"]
		if entry["action"] == action and f <= step and step < t:
			return true
	return false

## Alle bei einem Schritt gedrükten Aktionen, sortiert und ohne Duplikate
func pressed_at(step: int) -> Array[String]:
	var result: Array[String] = []
	for entry in holds:
		var f: int = entry["from"]
		var t: int = entry["to"]
		if f <= step and step < t:
			result.append(entry["action"])
	result.sort()
	return result.duplicate(true)

## Alle Drück- und Loslass-Ereignisse, sortiert nach Schritt; bei gleichem Schritt Loslassen vor Drücken, dann nach Aktion
func events() -> Array[Dictionary]:
	var event_list: Array[Dictionary] = []
	for entry in holds:
		event_list.append({
			"step": entry["from"],
			"action": entry["action"],
			"pressed": true
		})
		event_list.append({
			"step": entry["to"],
			"action": entry["action"],
			"pressed": false
		})
	# Sortieren: nach Schritt, dann pressed:false vor true, dann nach Aktion
	event_list.sort_custom(func(a, b):
		if a["step"] != b["step"]:
			return a["step"] < b["step"]
		if a["pressed"] != b["pressed"]:
			return !a["pressed"]  # false vor true
		return a["action"] < b["action"]
	)
	return event_list

## Länge = größtes 'to' aller Holds, oder 0 bei keiner Eingabe
func length() -> int:
	var max_to: int = 0
	for entry in holds:
		var t: int = entry["to"]
		if t > max_to:
			max_to = t
	return max_to

## Loslass-Ereignisse für alle bei 'step' gedrükten Aktionen (nach Aktion sortiert)
func abort(step: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in holds:
		var f: int = entry["from"]
		var t: int = entry["to"]
		if f <= step and step < t:
			result.append({
				"step": step,
				"action": entry["action"],
				"pressed": false
			})
	result.sort_custom(func(a, b):
		return a["action"] < b["action"]
	)
	return result

## Als Dictionary serialisieren
func to_dict() -> Dictionary:
	return {
		"holds": holds
	}

## Aus Dictionary rekonstruieren; Schritte als int konvertieren
static func from_dict(d: Dictionary) -> InputSequence:
	var seq: InputSequence = InputSequence.new()
	if not d.has("holds"):
		return seq
	for entry in d["holds"]:
		var h: Dictionary = {
			"action": str(entry["action"]),
			"from": int(entry["from"]),
			"to": int(entry["to"])
		}
		seq.holds.append(h)
	return seq
