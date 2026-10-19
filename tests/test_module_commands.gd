extends "res://tests/base_test.gd"

var command_registry: CommandRegistry
var module_registry: ModuleRegistry


func setup() -> void:
	command_registry = CommandRegistry.new()
	module_registry = ModuleRegistry.new()

	# Module anlegen: physik (nicht optional), beispiel
	var physik := ModuleManifest.new()
	physik.id = "physik"
	physik.name = "Physik"
	physik.version = "1.0.0"
	physik.optional = false
	module_registry.add(physik)

	var beispiel: ModuleManifest = ModuleManifest.new()
	beispiel.id = "beispiel"
	beispiel.name = "Beispiel"
	beispiel.version = "1.0.0"
	module_registry.add(beispiel)

	# Befehle registrieren
	ModuleCommands.register_all(command_registry, module_registry)


func test_registriert() -> void:
	check(command_registry.has_command("module.list"), "module.list registriert")
	check(command_registry.has_command("module.enable"), "module.enable registriert")
	check(command_registry.has_command("module.disable"), "module.disable registriert")


func test_liste() -> void:
	var ergebnis := command_registry.execute("module.list", {})
	check(ergebnis.is_ok(), "module.list ok")

	var data: Dictionary = ergebnis.data
	check(data.has("modules"), "data.modules vorhanden")

	var modules: Array[Dictionary] = data["modules"]
	check_eq(modules.size(), 2, "zwei Module in Liste")

	# erster Eintrag muss "beispiel" sein (alphabetisch sortiert)
	check_eq(modules[0].id, "beispiel", "erster Eintrag id example")


func test_aktivieren() -> void:
	var ergebnis := command_registry.execute("module.enable", {"id": "beispiel"})
	check(ergebnis.is_ok(), "module enable beispiel ok")

	check(module_registry.is_enabled("beispiel"), "beispiel nach enable aktiviert")


func test_unbekannt() -> void:
	var ergebnis := command_registry.execute("module.enable", {"id": "gibtsnicht"})
	check(ergebnis.code == "not_found", "unbekanntes Modul führt zu not_found")


func test_notwendig() -> void:
	# physik aktivieren (optional = false)
	module_registry.enable("physik")

	var ergebnis := command_registry.execute("module.disable", {"id": "physik"})
	check(ergebnis.code == "dependency", "disable notwendig führt zu dependency")
	check("Modul physik ist notwendig" in ergebnis.message, "richtige Meldung für notwendiges Modul")


func test_parameter_fehlt() -> void:
	var ergebnis := command_registry.execute("module.enable", {})
	check(ergebnis.code == "invalid_argument", "fehlender Parameter führt zu invalid_argument")
