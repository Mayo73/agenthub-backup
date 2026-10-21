extends "res://tests/base_test.gd"
## Abnahmetest: Module einbinden, deaktivieren, abweisen (Meilenstein „Abnahme", Kriterium 5).

var reg: ModuleRegistry


func _modul(id: String, api: int, reqs: Array[String] = []) -> ModuleManifest:
	var m := ModuleManifest.new()
	m.id = id
	m.name = id.capitalize()
	m.version = "1.0.0"
	m.engine_api = api
	m.requires = reqs
	return m


func setup() -> void:
	reg = ModuleRegistry.new()


func test_einbinden() -> void:
	var r: CommandResult = reg.add(_modul("beispiel", 1))
	check(r.code == "ok", "add sollte ok sein")
	r = reg.enable("beispiel")
	check(r.code == "ok", "enable sollte ok sein")
	check(reg.is_enabled("beispiel"), "beispiel sollte aktiviert sein")
	r = reg.disable("beispiel")
	check(r.code == "ok", "disable sollte ok sein")
	check(not reg.is_enabled("beispiel"), "beispiel sollte deaktiviert sein")


func test_inkompatibel() -> void:
	var r: CommandResult = reg.add(_modul("alt", 2))
	check(r.code == "incompatible", "inkompatibles Modul sollte abgewiesen werden")
	check("Engine-Schnittstelle" in r.message, "Meldung sollte Engine-Schnittstelle erwähnen")
	check(not reg.modules.has("alt"), "Modul sollte nicht registriert sein")
	r = reg.enable("alt")
	check(r.code == "not_found", "enable von abgewiesenem Modul sollte not_found sein")


func test_bestehende_bleiben() -> void:
	reg.add(_modul("beispiel", 1))
	reg.enable("beispiel")
	check(reg.is_enabled("beispiel"), "beispiel sollte aktiviert bleiben")
	var r: CommandResult = reg.add(_modul("alt", 2))
	check(r.code == "incompatible", "inkompatibles Modul sollte abgewiesen werden")
	check(reg.is_enabled("beispiel"), "beispiel sollte weiterhin aktiv sein")
	check(reg.list().size() == 1, "nur ein Modul sollte registriert sein")


func test_abhaengigkeit() -> void:
	reg.add(_modul("beispiel", 1))
	var r: CommandResult = reg.add(_modul("zusatz", 1, ["beispiel"]))
	r = reg.enable("zusatz")
	check(r.code == "dependency", "aktivierung ohne Abhängigkeit sollte fehlgeschlagen sein")
	check("beispiel" in r.message, "Meldung sollte abhängiges Modul erwähnen")
	reg.enable("beispiel")
	r = reg.enable("zusatz")
	check(r.code == "ok", "nach aktivieren von Beispiel sollte Zusatz aktivierbar sein")
	r = reg.disable("beispiel")
	check(r.code == "dependency", "deaktivierung mit Abhängigkeit sollte fehlgeschlagen sein")
	check("zusatz" in r.message, "Meldung sollte abhängiges Modul erwähnen")


func test_ungueltige_version() -> void:
	var m := ModuleManifest.new()
	m.id = "ungueltig"
	m.name = "Ungültig"
	m.version = "1.0"
	m.engine_api = 1
	var r: CommandResult = reg.add(m)
	check(r.code == "invalid_argument", "falsche Versionsnummer sollte abgewiesen werden")
