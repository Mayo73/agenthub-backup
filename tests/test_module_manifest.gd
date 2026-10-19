extends "res://tests/base_test.gd"

var manifest: ModuleManifest


func setup() -> void:
	manifest = ModuleManifest.new()


func test_laden() -> void:
	var d := {
		"id": "physik",
		"name": "Physik-Modul",
		"version": "1.0.0",
		"engine_api": 1.0,
		"requires": ["basis"],
		"optional": false,
		"capabilities": ["collision", "gravity"]
	}
	var m := ModuleManifest.from_dict(d)
	check(typeof(m.engine_api) == TYPE_INT, "engine_api ist INTEGER")
	check_eq(m.id, "physik", "id korrekt geladen")
	check_eq(m.name, "Physik-Modul", "name korrekt geladen")
	check_eq(m.version, "1.0.0", "version korrekt geladen")
	check_eq(m.requires, ["basis"], "requires gleich")
	check_eq(m.capabilities, ["collision", "gravity"], "capabilities gleich")


func test_pruefen() -> void:
	# Leeres Manifest → genau 2 Probleme
	var probleme := manifest.validate()
	check_eq(probleme.size(), 2, "2 Probleme bei leerem Manifest")
	check("id fehlt" in probleme, "id fehlt enthalten")
	check("name fehlt" in probleme, "name fehlt enthalten")

	# Mit id, name, aber Version 1.2 (falsche Form)
	manifest.id = "test"
	manifest.name = "Test-Modul"
	manifest.version = "1.2"
	probleme = manifest.validate()
	check_eq(probleme, ["version muss die Form 1.2.3 haben"], "version check funktioniert")
