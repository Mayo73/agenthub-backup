extends "res://tests/base_test.gd"


func test_frei() -> void:
	var result: String = NameUniquifier.unique("Gegner", [])
	check_eq(result, "Gegner", "freier Name bleibt unverändert")


func test_hochzaehlen() -> void:
	var taken1: Array = ["Gegner"]
	var result1: String = NameUniquifier.unique("Gegner", taken1)
	check_eq(result1, "Gegner2", "nächste Nummer wenn Belegt")

	var taken2: Array = ["Gegner", "Gegner2"]
	var result2: String = NameUniquifier.unique("Gegner", taken2)
	check_eq(result2, "Gegner3", "weitere hochzählen")

	var taken3: Array = ["Gegner2"]
	var result3: String = NameUniquifier.unique("Gegner2", taken3)
	check_eq(result3, "Gegner3", "Base+1 wenn Belegt")


func test_basis() -> void:
	var base1: String = NameUniquifier.base_name("Kiste07")
	check_eq(base1, "Kiste", "Ziffern am Ende entfernen")

	var base2: String = NameUniquifier.base_name("42")
	check_eq(base2, "Knoten", "nur Zahlen → Knoten")


func test_leer() -> void:
	var taken: Array = ["Knoten"]
	var result: String = NameUniquifier.unique("", taken)
	check_eq(result, "Knoten2", "leerer Name mit Belegung → Basis+1")
