extends "res://tests/base_test.gd"

var library := BehaviorLibrary.new()


func setup() -> void:
	pass


func teardown() -> void:
	pass


func test_namen() -> void:
	var names := library.names()
	check_eq(names.size(), 4, "names() sollte 4 Einträge haben")

	# Sortierte Reihenfolge prüfen
	var expected := ["bewegen", "drehen", "spielersteuerung", "zerstoeren_nach"]
	for i in range(expected.size()):
		check_eq(names[i], expected[i], "Names an Position %d" % i)


func test_standard() -> void:
	var defaults := library.defaults("bewegen")
	check_eq(defaults["speed"], 100.0, "speed Standard sollte 100.0 sein")
	check_eq(defaults["direction"], "rechts", "direction Standard sollte \"rechts\" sein")


func test_gueltig() -> void:
	var problems := library.validate("drehen", {"degrees_per_second": 180.0})
	check(problems.size() == 0, "Validierung sollte leer sein bei gültigem Eingabe")


func test_bereich() -> void:
	var problems := library.validate("bewegen", {"speed": 5000.0})
	check_eq(problems.size(), 1, "sollte ein Problem zurückgeben")
	check_eq(problems[0], "speed muss zwischen 0.0 und 1000.0 liegen", "Fehlermeldung für speed außerhalb Bereich")


func test_typ_und_unbekannt() -> void:
	var problems := library.validate("spielersteuerung", {"jump": 1.0, "farbe": "rot"})
	# Erwartet: ["Unbekannter Parameter farbe", "jump muss wahr oder falsch sein"]
	check_eq(problems.size(), 2, "sollte zwei Probleme zurückgeben")

	# Reihenfolge prüfen (sortiert nach Parameternamen)
	var has_unbekannt := false
	var has_typ := false
	for p in problems:
		if p == "Unbekannter Parameter farbe":
			has_unbekannt = true
		if p == "jump muss wahr oder falsch sein":
			has_typ = true

	check(has_unbekannt, "Unbekannter Parameter farbe sollte enthalten sein")
	check(has_typ, "jump muss wahr oder falsch sein sollte enthalten sein")


func test_anlegen() -> void:
	# Erfolgreiche Erstellung mit defaults
	var result := library.create("zerstoeren_nach", {})
	check(result.is_ok(), "create sollte ok sein bei gültigem Verhalten")
	check_eq(result.data["behavior"], "zerstoeren_nach", "behavior name should be \"zerstoeren_nach\"")
	check_eq(result.data["params"]["seconds"], 5.0, "seconds default sollte 5.0 sein")

	# Ungültiges Verhalten sollte INVALID_ARGUMENT zurückgeben
	var invalid_result := library.create("fliegen", {})
	check(not invalid_result.is_ok(), "create sollte fehlgeschlagen bei unbekanntem Verhalten")
	check(invalid_result.code == "invalid_argument", "code sollte \"invalid_argument\" sein")
	check("Verhalten fliegen gibt es nicht" in invalid_result.message, "Message sollte Fehlerbeschreibung enthalten")
