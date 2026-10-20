class_name EvolutionTimeline
extends RefCounted
## Verlauf der Entwicklungsschritte für den Zeitstrahl.


const START := "start"
const STAGE := "abschnitt"
const EDITOR := "editor"
const FISH := "fisch"
const FISH_SIZE := "fischgroesse"
const UPGRADE := "verbesserung"

const DIET_COLORS: Dictionary = {
	Diet.PFLANZENFRESSER: Color("#6CCB5F"),
	Diet.FLEISCHFRESSER: Color("#D9534F"),
	Diet.ALLESFRESSER: Color("#9B6CD9")
}

var entries: Array[Dictionary] = []


func add(kind: String, label: String, diet: String, time: float, color: Color, phase: String = "zelle") -> void:
	var entry := {
		"kind": kind,
		"label": label,
		"diet": diet,
		"time": float(time),
		"color": color,
		"phase": phase
	}
	entries.append(entry)


func add_without_phase(kind: String, label: String, diet: String, time: float, color: Color) -> void:
	add(kind, label, diet, time, color, "zelle")


func size() -> int:
	return entries.size()


func last() -> Dictionary:
	if entries.is_empty():
		return {}
	return entries[-1]


static func diet_color(diet: String) -> Color:
	if DIET_COLORS.has(diet):
		return DIET_COLORS[diet]
	return Color.GRAY


static func time_text(seconds: float) -> String:
	var minuten := int(seconds) / 60
	var sekunden := int(seconds) % 60
	return "%d:%02d" % [minuten, sekunden]


func count(kind: String) -> int:
	var c := 0
	for entry in entries:
		if entry["kind"] == kind:
			c += 1
	return c


func phase_time(phase: String) -> float:
	var times: Array[float] = []
	for entry in entries:
		if entry["phase"] == phase:
			times.append(entry["time"])
	if times.is_empty():
		return 0.0
	return times.max() - times.min()


func summary_lines() -> Array[String]:
	var lines: Array[String] = []
	lines.append("Entwicklungsschritte: %d" % size())
	lines.append("Editorbesuche: %d" % count(EDITOR))
	lines.append("Zeit als Zelle: %s" % time_text(phase_time("zelle")))

	if has_entries_with_phase(FISH):
		lines.append("Fischgrößen: %d" % count(FISH_SIZE))
		lines.append("Verbesserungen: %d" % count(UPGRADE))

	return lines


func has_entries_with_phase(phase: String) -> bool:
	for entry in entries:
		if entry["phase"] == phase:
			return true
	return false


func to_dict() -> Dictionary:
	var result := {"entries": []}
	for entry in entries:
		var dict_entry := {
			"kind": entry["kind"],
			"label": entry["label"],
			"diet": entry["diet"],
			"time": float(entry["time"]),
			"color": [entry["color"].r, entry["color"].g, entry["color"].b, entry["color"].a],
			"phase": entry["phase"]
		}
		result.entries.append(dict_entry)
	return result


static func from_dict(d: Dictionary) -> EvolutionTimeline:
	var timeline := EvolutionTimeline.new()
	for item in d.entries:
		var color_arr := item.color as Array
		var color := Color(color_arr[0], color_arr[1], color_arr[2], color_arr[3])
		var time := float(item.time)
		timeline.add(
			item.kind,
			item.label,
			item.diet,
			time,
			color,
			item.phase
		)
	return timeline
