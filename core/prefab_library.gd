extends RefCounted
class_name PrefabLibrary

## Kollisionsergebnisse und Statuscodes aus CommandResult importieren
const CODE_OK := "ok"
const UNKNOWN_COMMAND := "unknown_command"
const INVALID_ARGUMENT := "invalid_argument"
const NOT_FOUND := "not_found"
const CONFLICT := "conflict"
const FORBIDDEN_PATH := "forbidden_path"
const DEPENDENCY := "dependency"
const INCOMPATIBLE := "incompatible"
const EXEC_FAILED := "failed"

## Vorlagen-Speicher: Kennung → Prefab
var prefabs: Dictionary = {}

## Zähler für fortlaufende IDs: Kennung → int
var counters: Dictionary = {}


func add(prefab: Prefab) -> CommandResult:
	## Neue Vorlage hinzufügen
	# Leere ID prüfen
	if prefab.id == "":
		return CommandResult.error(INVALID_ARGUMENT, "Vorlage braucht eine Kennung")

	# Bereits vorhandene ID prüfen
	if prefabs.has(prefab.id):
		return CommandResult.error(CONFLICT, "Vorlage %s gibt es schon" % prefab.id)

	# Vorlage speichern
	prefabs[prefab.id] = prefab

	return CommandResult.success({"id": prefab.id})


func get_prefab(prefab_id: String) -> Prefab:
	## Vorlage nach Kennung abrufen, oder null wenn nicht vorhanden
	if prefabs.has(prefab_id):
		return prefabs[prefab_id]
	return null


func spawn(prefab_id: String, overrides: Dictionary = {}) -> CommandResult:
	## Neues Objekt aus Vorlage erzeugen mit fortlaufender Kennung

	# Vorlage existiert?
	if not prefabs.has(prefab_id):
		return CommandResult.error(NOT_FOUND, "Vorlage %s gibt es nicht" % prefab_id)

	# Zähler erhöhen und neue ID erstellen
	var zaehler := int(counters.get(prefab_id, 0)) + 1
	counters[prefab_id] = zaehler

	var kennung: String = "%s-%d" % [prefab_id, zaehler]

	# Objekt instanziieren
	var obj: Dictionary = prefabs[prefab_id].instantiate(kennung, overrides)

	return CommandResult.success({"object": obj})


func ids() -> Array[String]:
	## Alle Kennungen sortiert zurückgeben
	var a: Array[String] = []
	for id in prefabs:
		a.append(id)
	a.sort()
	return a


func to_dict() -> Dictionary:
	## Library als Dictionary exportieren (JSON-fähig)
	var prefabs_list := []

	# Vorlagen nach Kennung sortiert hinzufügen
	var ids_sorted := ids()
	for id in ids_sorted:
		prefabs_list.append(prefabs[id].to_dict())

	return {
		"prefabs": prefabs_list,
		"counters": counters.duplicate()
	}


static func from_dict(d: Dictionary) -> PrefabLibrary:
	## Library aus Dictionary rekonstruieren
	var lib := PrefabLibrary.new()

	# Vorlagen laden
	for p in d.get("prefabs", []):
		var prefab: Prefab = Prefab.from_dict(p)
		if not prefab.id.is_empty():
			lib.prefabs[prefab.id] = prefab

	# Zähler laden (als float aus JSON → int konvertieren)
	for k in d.get("counters", {}):
		var v: float = d.get("counters", {}).get(k, 0.0)
		lib.counters[k] = int(v)

	return lib
