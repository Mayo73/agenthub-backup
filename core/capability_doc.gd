class_name CapabilityDoc
extends RefCounted
## Erzeugt Markdown-Ausgaben aus dem CommandRegistry.

## Schlüssel sortieren, je "name: typ", mit ", " verbinden; leeres Dictionary → "–".
static func params_text(params: Dictionary) -> String:
	var keys: Array[String] = []
	for key in params.keys():
		keys.append(key as String)
	keys.sort()

	if keys.is_empty():
		return "–"

	var result: Array[String] = []
	for key in keys:
		result.append("%s: %s" % [key, params[key]])

	return ", ".join(result)


## Teil vor dem ersten Punkt; ohne Punkt der ganze Name.
static func group_of(name: String) -> String:
	var idx := name.find(".")
	if idx >= 0:
		return name.substr(0, idx)
	return name


## Markdown-Tabelle aller Befehle aus dem Registry.
static func markdown(registry: CommandRegistry) -> String:
	var lines: Array[String] = []
	lines.append("# Fähigkeitenverzeichnis")
	lines.append("")
	lines.append("| Befehl | Gruppe | Parameter | Beschreibung |")
	lines.append("|---|---|---|---|")

	var capabilities := registry.capabilities()
	for cap in capabilities:
		var name: String = cap["name"] as String
		var description: String = cap["description"] as String
		var params: Dictionary = cap["params"] as Dictionary
		var group: String = group_of(name)
		var params_str: String = params_text(params)

		lines.append("| %s | %s | %s | %s |" % [name, group, params_str, description])

	return "\n".join(lines)


## Alle Gruppen sortiert, ohne Doppelte.
static func groups(registry: CommandRegistry) -> Array[String]:
	var all_groups: Dictionary = {}

	var capabilities := registry.capabilities()
	for cap in capabilities:
		var name: String = cap["name"] as String
		var group: String = group_of(name)
		all_groups[group] = true

	var result: Array[String] = []
	for group in all_groups.keys():
		result.append(group)

	result.sort()
	return result
