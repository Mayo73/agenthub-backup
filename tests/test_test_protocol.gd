extends "res://tests/base_test.gd"

var p: TestProtocol


func setup() -> void:
	p = TestProtocol.new()


func test_messung() -> void:
	check(p.measure("weite", 10.02, 10.0, 0.05), "weite innerhalb der Toleranz")
	check(not p.measure("hoehe", 3.0, 2.0, 0.5), "hoehe außerhalb der Toleranz")
	check(not p.passed(), "nicht bestanden")
	var failures: Array[String] = p.failures()
	check_eq(failures.size(), 1, "eine fehlgeschlagene Messung")
	check(failures[0].contains("hoehe"), "Meldung nennt hoehe")


func test_leer() -> void:
	check(not p.passed(), "ohne Messungen nicht bestanden")


func test_markdown() -> void:
	p.name = "wurf"
	p.add_input(1, "fire", true)
	p.measure("weite", 10.02, 10.0, 0.05)
	var text: String = p.markdown()
	check(text.contains("# Testprotokoll wurf"), "Überschrift")
	check(text.contains("| weite |"), "Tabellenzeile")
	check(text.contains("Ergebnis: bestanden"), "Ergebnis")


func test_speichern() -> void:
	p.seed_value = 42
	p.add_input(3, "jump", true)
	p.add_input(9, "jump", false)
	p.measure("weite", 10.02, 10.0, 0.05)
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(p.to_dict()))
	var q: TestProtocol = TestProtocol.from_dict(parsed)
	check_eq(q.seed_value, 42, "Seed")
	check_eq(q.inputs.size(), 2, "Eingaben")
	check_eq(q.measurements.size(), 1, "Messungen")
	check_eq(q.passed(), p.passed(), "Ergebnis")
