extends "res://tests/base_test.gd"

var test_data: Dictionary


func setup() -> void:
	test_data = {
		"a": Rect2(0, 0, 10, 10),
		"b": Rect2(20, 0, 10, 10),
		"c": Rect2(5, 5, 2, 2)
	}


func test_beruehren() -> void:
	var result := SelectionBox.pick(test_data, Rect2(4, 4, 22, 4))
	check_eq(result, ["a", "b", "c"], "Berührende Objekte auswählen")


func test_innen() -> void:
	var result := SelectionBox.pick(test_data, Rect2(4, 4, 22, 4), "inside")
	check_eq(result, ["c"], "Nur vollständig eingeschlossene Objekte")


func test_rueckwaerts() -> void:
	var result := SelectionBox.pick(test_data, Rect2(15, 15, -15, -15))
	check_eq(result, ["a", "c"], "Rückwärts aufgezogenes Rechteck")


func test_leer() -> void:
	var result := SelectionBox.pick(test_data, Rect2(100, 100, 5, 5))
	check_eq(result, [], "Keine Auswahl bei leerem Ergebnis")
