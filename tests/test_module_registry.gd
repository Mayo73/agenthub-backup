extends "res://tests/base_test.gd"

var registry: ModuleRegistry


func setup() -> void:
	registry = ModuleRegistry.new()
	# Module anlegen: physik (nicht optional), ballistik (braucht physik), beispiel (ohne Abhängigkeiten)
	var physik := ModuleManifest.new()
	physik.id = "physik"
	physik.name = "Physik"
	physik.version = "1.0.0"
	physik.optional = false
	registry.add(physik)

	var ballistik: ModuleManifest = ModuleManifest.new()
	ballistik.id = "ballistik"
	ballistik.name = "Ballistik"
	ballistik.version = "1.0.0"
	ballistik.requires.append("physik")
	registry.add(ballistik)

	var beispiel: ModuleManifest = ModuleManifest.new()
	beispiel.id = "beispiel"
	beispiel.name = "Beispiel"
	beispiel.version = "1.0.0"
	registry.add(beispiel)


func test_aufnehmen_und_aktivieren() -> void:
	check_eq(registry.modules.size(), 3, "alle drei add ok")

	# enable ballistik ohne physik → dependency error
	var ergebnis := registry.enable("ballistik")
	check(ergebnis.code == "dependency", "enable ballistik dependency")
	check("Modul ballistik braucht zuerst: physik" in ergebnis.message, "Meldung dependency")

	# erst physik aktivieren
	ergebnis = registry.enable("physik")
	check(ergebnis.is_ok(), "enable physik ok")

	# jetzt ballistik aktivieren → ok
	ergebnis = registry.enable("ballistik")
	check(ergebnis.is_ok(), "enable ballistik nach physik ok")


func test_inkompatibel() -> void:
	var neu: ModuleManifest = ModuleManifest.new()
	neu.id = "neu"
	neu.name = "Neu"
	neu.version = "1.0.0"
	neu.engine_api = 2

	var ergebnis := registry.add(neu)
	check(ergebnis.code == "incompatible", "inkompatible Meldung")
	check("Modul neu braucht Engine-Schnittstelle 2, vorhanden ist 1" in ergebnis.message, "Meldung incompatible")
	check(not registry.modules.has("neu"), "modules.has(neu) falsch → Modul wurde nicht aufgenommen")


func test_abschalten() -> void:
	registry.enable("beispiel")
	check(registry.is_enabled("beispiel"), "beispiel aktiviert")

	var ergebnis := registry.disable("beispiel")
	check(ergebnis.is_ok(), "disable beispiel ok")
	check(not registry.is_enabled("beispiel"), "is_enabled(beispiel) falsch")


func test_notwendig() -> void:
	# physik aktivieren (optional = false)
	registry.enable("physik")

	var ergebnis := registry.disable("physik")
	check(ergebnis.code == "dependency", "disable notwenig dependency")
	check("Modul physik ist notwendig" in ergebnis.message, "Meldung notwendig")


func test_gebraucht() -> void:
	# Zusätzlich: effekte braucht ballistik
	var effekte: ModuleManifest = ModuleManifest.new()
	effekte.id = "effekte"
	effekte.name = "Effekte"
	effekte.version = "1.0.0"
	effekte.requires.append("ballistik")
	registry.add(effekte)

	# physik, ballistik, effekte aktivieren
	registry.enable("physik")
	registry.enable("ballistik")
	registry.enable("effekte")

	var ergebnis := registry.disable("ballistik")
	check(ergebnis.code == "dependency", "disable ballistik dependency")
	check("Modul ballistik wird gebraucht von: effekte" in ergebnis.message, "Meldung gebraucht von effekte")


func test_liste() -> void:
	var liste: Array[Dictionary] = registry.list()
	var ids: Array[String] = []
	for m in liste:
		ids.append(m.id)
	check_eq(ids, ["ballistik", "beispiel", "physik"], "list() sortiert nach id")

	registry.enable("physik")
	liste = registry.list()
	for m in liste:
		if m.id == "physik":
			check(m.enabled, "nur physik enabled")
		else:
			check(not m.enabled, "%s nicht enabled" % m.id)
