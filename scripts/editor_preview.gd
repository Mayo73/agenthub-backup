class_name EditorPreview
extends RefCounted
## Fähigkeitsvorschau im Zelleditor: Werte vorher und nachher als Textzeilen.

const DIET_NAMES := {
	"pflanzenfresser": "Pflanzenfresser",
	"fleischfresser": "Fleischfresser",
	"allesfresser": "Allesfresser",
	"": "keine Nahrung",
}


static func diet_name(diet: String) -> String:
	return str(DIET_NAMES.get(diet, diet))


## Namen der eingebauten Waffen (Kategorie "waffe"), jede Art nur einmal, in Einbaureihenfolge.
static func weapons(build: CellBuild) -> Array[String]:
	var result: Array[String] = []
	for p in build.parts:
		var id: String = p["id"]
		if PartCatalog.category_of(id) == "waffe" and not result.has(PartCatalog.name_of(id)):
			result.append(PartCatalog.name_of(id))
	return result


## "Tempo: 220 → 280"; bei gleichem Wert ohne Pfeil: "Tempo: 220".
static func line(label: String, before: String, after: String) -> String:
	if before == after:
		return "%s: %s" % [label, before]
	return "%s: %s → %s" % [label, before, after]


static func lines(original: CellBuild, working: CellBuild, stage: int) -> Array[String]:
	var result: Array[String] = []
	result.append(line("Tempo", str(roundi(CellStats.max_speed(original, stage))), str(roundi(CellStats.max_speed(working, stage)))))
	result.append(line("Wendigkeit", "%.1f" % CellStats.turn_rate(original), "%.1f" % CellStats.turn_rate(working)))
	result.append(line("Ernährung", diet_name(CellStats.diet(original)), diet_name(CellStats.diet(working))))
	var names := ", ".join(PackedStringArray(weapons(working)))
	result.append("Waffen: %s" % (names if names != "" else "keine"))
	return result
