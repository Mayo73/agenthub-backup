class_name AiRecipes
extends RefCounted
## Erprobte KI-Rezepte: Vorlagen für Aufträge an das KI-Modell mit Platzhaltern {name}.

const RECIPES := {
	"spielfigur": {
		"title": "Spielfigur anlegen",
		"template": "Lege eine steuerbare Spielfigur namens {name} an, Geschwindigkeit {tempo} Einheiten/s, Sprunghöhe {sprung} Einheiten.",
		"defaults": {"tempo": 5, "sprung": 2},
	},
	"kamera": {
		"title": "Kamera folgen lassen",
		"template": "Lass die Kamera {ziel} folgen, Totzone {totzone} Einheiten.",
		"defaults": {"totzone": 2},
	},
	"hindernisse": {
		"title": "Hindernisse verteilen",
		"template": "Verteile {anzahl} Hindernisse zwischen x={von} und x={bis}.",
		"defaults": {"anzahl": 5},
	},
	"ausloeser": {
		"title": "Auslösebereich anlegen",
		"template": "Lege einen Auslösebereich {name} an, der beim Betreten {aktion} auslöst.",
		"defaults": {},
	},
	"testlauf": {
		"title": "Testlauf schreiben",
		"template": "Schreibe einen Testlauf: {eingaben}. Erwartet: {erwartung}.",
		"defaults": {},
	},
}


static func names() -> Array[String]:
	var result: Array[String] = []
	for key: String in RECIPES:
		result.append(key)
	result.sort()
	return result


static func placeholders(name: String) -> Array[String]:
	var result: Array[String] = []
	if not RECIPES.has(name):
		return result
	var text: String = RECIPES[name]["template"]
	var regex := RegEx.new()
	regex.compile("[{]([^{}]+)[}]")
	for m: RegExMatch in regex.search_all(text):
		var p := m.get_string(1)
		if not result.has(p):
			result.append(p)
	result.sort()
	return result


static func fill(name: String, values: Dictionary) -> CommandResult:
	if not RECIPES.has(name):
		return CommandResult.error(CommandResult.NOT_FOUND, "Rezept %s gibt es nicht" % name)
	var recipe: Dictionary = RECIPES[name]
	var merged: Dictionary = recipe["defaults"].duplicate()
	merged.merge(values, true)
	var missing: Array[String] = []
	for p in placeholders(name):
		if not merged.has(p):
			missing.append(p)
	if not missing.is_empty():
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Es fehlen: " + ", ".join(missing))
	var text: String = recipe["template"]
	for p in placeholders(name):
		text = text.replace("{" + p + "}", str(merged[p]))
	return CommandResult.success({"prompt": text, "title": recipe["title"]})
