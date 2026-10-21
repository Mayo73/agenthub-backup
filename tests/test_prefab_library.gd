extends "res://tests/base_test.gd"

var lib: PrefabLibrary
var pref: Prefab
var cmd_result: CommandResult


func setup() -> void:
	## Vor jedem Test eine leere Library erstellen
	lib = PrefabLibrary.new()
	# Eine Start-Vorlage hinzufügen
	lib.add(Prefab.new("kiste", "RigidBody2D", {"mass": 2.0}))


func test_anlegen() -> void:
	## Doppelte Kennung führt zu CONFLICT, leere Kennung zu INVALID_ARGUMENT

	# Bereits vorhandene ID → CONFLICT
	var duplicate := Prefab.new("kiste")
	var result1: CommandResult = lib.add(duplicate)
	check_eq(result1.code, "conflict", "doppelte ID sollte conflict ergeben")

	# Leere ID → INVALID_ARGUMENT
	var empty_id := Prefab.new("")
	var result2: CommandResult = lib.add(empty_id)
	check_eq(result2.code, "invalid_argument", "leere ID sollte invalid_argument ergeben")


func test_erzeugen() -> void:
	## Spawn erzeugt fortlaufende IDs, unbekannte Vorlage liefert NOT_FOUND

	# Zwei Objekte aus existierender Vorlage erzeugen
	var spawn1 := lib.spawn("kiste")
	check_eq(spawn1.code, "ok", "erster spawn sollte ok sein")
	var obj1_dict: Dictionary = spawn1.data["object"] as Dictionary
	check(obj1_dict.get("id") == "kiste-1", "erstes Objekt muss id 'kiste-1' haben")

	var spawn2 := lib.spawn("kiste")
	check_eq(spawn2.code, "ok", "zweiter spawn sollte ok sein")
	var obj2_dict: Dictionary = spawn2.data["object"] as Dictionary
	check(obj2_dict.get("id") == "kiste-2", "zweites Objekt muss id 'kiste-2' haben")

	# Unbekannte Vorlage → NOT_FOUND
	var unknown := lib.spawn("fass")
	check_eq(unknown.code, "not_found", "unbekannte Vorlage sollte not_found ergeben")


func test_ueberschreiben() -> void:
	## Overrides werden korrekt angewendet

	var spawn := lib.spawn("kiste", {"mass": 5.0})
	check_eq(spawn.code, "ok", "spawn mit overrides sollte ok sein")

	var obj_dict: Dictionary = spawn.data["object"] as Dictionary
	var props: Dictionary = obj_dict.get("props", {}) as Dictionary
	# Typcast explizit für int-Konvertierung aus JSON
	var mass := float(props.get("mass", 0.0))
	check_eq(mass, 5.0, "override mass soll 5.0 sein")


func test_speichern() -> void:
	## Serialisierung/Desserialisierung erhält Zählerstatus

	# Zwei Objekte erzeugen
	lib.spawn("kiste")
	lib.spawn("kiste")

	# Library serialisieren
	var d := lib.to_dict()
	check(d.has("prefabs"), "to_dict muss 'prefabs' enthalten")
	check(d.has("counters"), "to_dict muss 'counters' enthalten")

	# Library deserialisieren
	var restored := PrefabLibrary.from_dict(d)

	# Nächster spawn soll kiste-3 ergeben
	var next_spawn := restored.spawn("kiste")
	check_eq(next_spawn.code, "ok", "spawn nach restore sollte ok sein")
	var next_obj: Dictionary = next_spawn.data["object"] as Dictionary
	check(next_obj.get("id") == "kiste-3", "nach 2 spawns muss id 'kiste-3' folgen")

	# ids() muss ["kiste"] liefern
	var ids_array := restored.ids()
	check_eq(ids_array.size(), 1, "ids() soll Größe 1 haben")
	check(ids_array[0] == "kiste", "ids() muss ['kiste'] zurückgeben")
