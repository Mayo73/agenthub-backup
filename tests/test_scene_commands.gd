extends "res://tests/base_test.gd"

var registry: CommandRegistry
var model: SceneModel


func setup() -> void:
	registry = CommandRegistry.new()
	model = SceneModel.new()
	SceneCommands.register_all(registry, model)


func test_anlegen() -> void:
	var result := registry.execute("scene.add", {"type": "Node2D", "parent": "", "props": {}})
	check(result.is_ok(), "scene.add sollte erfolgreich sein")
	var data := result.data as Dictionary
	check(data.has("id"), "Ergebnis sollte Kennung enthalten")
	var id: String = data["id"]
	check(id == "o1", "Erste Kennung soll 'o1' sein")
	check(model.has_object("o1"), "Objekt o1 soll im Modell existieren")


func test_eltern_fehlt() -> void:
	var result := registry.execute("scene.add", {"type": "Node2D", "parent": "o9", "props": {}})
	check(not result.is_ok(), "Sollte fehlschlagen, wenn Eltern fehlt")
	check(result.code == CommandResult.NOT_FOUND, "Code soll NOT_FOUND sein")


func test_setzen_und_lesen() -> void:
	# Erst Objekt anlegen
	var add_result := registry.execute("scene.add", {"type": "Node2D", "parent": "", "props": {}})
	check(add_result.is_ok(), "Anlegen sollte erfolgreich sein")

	# Eigenschaft setzen
	var set_result := registry.execute("scene.set", {"id": "o1", "key": "mass", "value": 3.0})
	check(set_result.is_ok(), "Setzen sollte erfolgreich sein")
	var set_data: Dictionary = set_result.data
	check(set_data["key"] == "mass", "Schlüssel soll 'mass' sein")

	# Eigenschaft lesen
	var get_result := registry.execute("scene.get", {"id": "o1"})
	check(get_result.is_ok(), "Lesen sollte erfolgreich sein")
	var obj: Dictionary = get_result.data
	var mass_val: float = obj["props"]["mass"]
	check_eq(mass_val, 3.0, "Wert soll 3.0 sein")


func test_entfernen() -> void:
	# Erst Objekt anlegen
	var add_result := registry.execute("scene.add", {"type": "Node2D", "parent": "", "props": {}})
	check(add_result.is_ok(), "Anlegen sollte erfolgreich sein")

	# Objekt entfernen
	var remove_result := registry.execute("scene.remove", {"id": "o1"})
	check(remove_result.is_ok(), "Entfernen sollte erfolgreich sein")

	# Danach sollte get nicht mehr funktionieren
	var get_result := registry.execute("scene.get", {"id": "o1"})
	check(not get_result.is_ok(), "Nach Entfernen soll GET fehlschlagen")
	check(get_result.code == CommandResult.NOT_FOUND, "Code soll NOT_FOUND sein")


func test_liste_und_kopie() -> void:
	# Erst Objekt anlegen
	var add_result := registry.execute("scene.add", {"type": "Node2D", "parent": "", "props": {}})
	check(add_result.is_ok(), "Anlegen sollte erfolgreich sein")

	# Duplizieren
	var dup_result := registry.execute("scene.duplicate", {"id": "o1"})
	check(dup_result.is_ok(), "Duplizieren sollte erfolgreich sein")
	var dup_data: Dictionary = dup_result.data
	check(dup_data["id"] == "o2", "Duplikat soll 'o2' sein")

	# Liste abfragen
	var list_result := registry.execute("scene.list", {"parent": ""})
	check(list_result.is_ok(), "Liste sollte erfolgreich sein")
	var list_data: Dictionary = list_result.data
	var ids: Array[String] = list_data["ids"]
	check(ids.size() == 2, "Soll zwei Objekte enthalten")
	check("o1" in ids, "o1 soll in Liste sein")
	check("o2" in ids, "o2 soll in Liste sein")


func test_verzeichnis() -> void:
	var caps := registry.capabilities()
	check(caps.size() == 6, "Verzeichnis soll 6 Einträge haben")

	for cap: Dictionary in caps:
		check(not cap["description"].is_empty(), "Jeder Eintrag soll Beschreibung haben")
