class_name ModuleRegistry
extends RefCounted
## Registry für Module, verwaltet Hinzufügen, Aktivieren und Deaktivieren.

const ENGINE_API := 1

var modules: Dictionary = {}
var enabled: Array[String] = []


func add(m: ModuleManifest) -> CommandResult:
	var probleme := m.validate()
	if not probleme.is_empty():
		var meldung := "; ".join(probleme)
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, meldung)
	if m.engine_api != ENGINE_API:
		var meldung := "Modul %s braucht Engine-Schnittstelle %d, vorhanden ist %d"
		return CommandResult.error(CommandResult.INCOMPATIBLE, meldung % [m.id, m.engine_api, ENGINE_API])
	modules[m.id] = m
	return CommandResult.success({"id": m.id})


func enable(id: String) -> CommandResult:
	if not modules.has(id):
		var meldung := "Modul %s gibt es nicht"
		return CommandResult.error(CommandResult.NOT_FOUND, meldung % [id])
	var fehlende: Array[String] = []
	for req in (modules[id] as ModuleManifest).requires:
		if not enabled.has(req):
			fehlende.append(req)
	if not fehlende.is_empty():
		var meldung := "Modul %s braucht zuerst: %s"
		return CommandResult.error(CommandResult.DEPENDENCY, meldung % [id, ", ".join(fehlende)])
	if not enabled.has(id):
		enabled.append(id)
	return CommandResult.success({"id": id})


func disable(id: String) -> CommandResult:
	if not modules.has(id):
		return CommandResult.error(CommandResult.NOT_FOUND, "Modul %s gibt es nicht" % id)
	var m: ModuleManifest = modules[id]
	if not m.optional:
		var meldung := "Modul %s ist notwendig"
		return CommandResult.error(CommandResult.DEPENDENCY, meldung % [id])
	var wird_braucht_von: Array[String] = []
	for eid in enabled:
		if modules.has(eid) and (modules[eid] as ModuleManifest).requires.has(id):
			wird_braucht_von.append(eid)
	if not wird_braucht_von.is_empty():
		var meldung := "Modul %s wird gebraucht von: %s"
		return CommandResult.error(CommandResult.DEPENDENCY, meldung % [id, ", ".join(wird_braucht_von)])
	enabled.erase(id)
	return CommandResult.success({"id": id})


func is_enabled(id: String) -> bool:
	return enabled.has(id)


func list() -> Array[Dictionary]:
	var ergebnis: Array[Dictionary] = []
	for id in modules.keys():
		var m: ModuleManifest = modules[id]
		ergebnis.append(m.to_dict().merged({"enabled": is_enabled(id)}))
	ergebnis.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a["id"]) < str(b["id"]))
	return ergebnis
