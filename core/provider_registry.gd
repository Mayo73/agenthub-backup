class_name ProviderRegistry
extends RefCounted
## Verzeichnis der KI-Anbieter mit Zustand und Auswahl.

var providers: Dictionary = {}  ## Kennung -> {"id": String, "name": String, "kind": String, "available": bool, "priority": int}
var preferred := ""

const KIND_LOKAL := "lokal"
const KIND_HUB := "hub"


func add(id: String, name: String, kind: String, priority: int = 5) -> CommandResult:
	## Einen Anbieter hinzufügen.
	if kind != KIND_LOKAL and kind != KIND_HUB:
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Art %s ist unbekannt" % [kind])

	if providers.has(id):
		return CommandResult.error(CommandResult.CONFLICT, "Anbieter %s gibt es schon" % [id])

	providers[id] = {
		"id": id,
		"name": name,
		"kind": kind,
		"available": false,
		"priority": priority
	}

	return CommandResult.success({"id": id})


func set_available(id: String, available: bool) -> bool:
	## Verfügbarkeit eines Anbieters setzen.
	if not providers.has(id):
		return false

	providers[id]["available"] = available
	return true


func prefer(id: String) -> CommandResult:
	## Einen Anbieter als bevorzugt markieren.
	if not providers.has(id):
		return CommandResult.error(CommandResult.NOT_FOUND, "Anbieter %s gibt es nicht" % [id])

	preferred = id
	return CommandResult.success({})


func active() -> CommandResult:
	## Den aktiven (erreichbaren) Anbieter ermitteln.
	if not preferred.is_empty() and providers.has(preferred):
		if providers[preferred]["available"]:
			var p: Dictionary = providers[preferred]
			return CommandResult.success({"id": p["id"], "name": p["name"]})

	## Erreichbaren mit kleinster priority suchen.
	var best_id: String = ""
	var best_priority := 999999

	for id in providers:
		var p: Dictionary = providers[id]
		if p["available"] and p["priority"] < best_priority:
			best_priority = p["priority"]
			best_id = id
		elif p["available"] and p["priority"] == best_priority:
			if best_id.is_empty() or id < best_id:
				best_id = id

	if not best_id.is_empty():
		var p: Dictionary = providers[best_id]
		return CommandResult.success({"id": p["id"], "name": p["name"]})

	## Keiner erreichbar.
	return CommandResult.error(CommandResult.DEPENDENCY, "Kein KI-Anbieter erreichbar. Manuelles Bearbeiten, Speichern, Spielen und Export funktionieren weiter.")


func status_text() -> String:
	## Status-Text für alle Anbieter (Kennungen sortiert).
	if providers.is_empty():
		return "Keine KI-Anbieter eingerichtet"

	var lines := Array()
	for id in providers.keys():
		lines.append(id)
	lines.sort()

	for i in range(lines.size()):
		var id: String = lines[i]
		var p: Dictionary = providers[id]
		var status: String = "nicht erreichbar" if not p["available"] else "erreichbar"
		lines[i] = "%s: %s" % [p["name"], status]

	return "\n".join(lines)
