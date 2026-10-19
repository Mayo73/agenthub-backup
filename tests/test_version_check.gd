extends "res://tests/base_test.gd"


func test_lesen() -> void:
	check_eq(VersionCheck.parse("1.2.3"), [1, 2, 3], "gültige Version")
	check_eq(VersionCheck.parse("1.2"), [], "zu wenig Teile")
	check_eq(VersionCheck.parse("a.b.c"), [], "nicht-ganzzahlige Teile")


func test_vergleich() -> void:
	check_eq(VersionCheck.compare("1.2.3", "1.10.0"), -1, "minor 2 < 10")
	check_eq(VersionCheck.compare("2.0.0", "1.9.9"), 1, "major 2 > 1")
	check_eq(VersionCheck.compare("1.0.0", "1.0.0"), 0, "gleiche Versionen")


func test_anforderung() -> void:
	check(VersionCheck.satisfies("1.2.0", ">=1.1.0"), "1.2.0 >= 1.1.0")
	check(not VersionCheck.satisfies("1.0.0", ">=1.1.0"), "1.0.0 nicht >= 1.1.0")
	check(VersionCheck.satisfies("1.0.0", "<2.0.0"), "1.0.0 < 2.0.0")
	check(VersionCheck.satisfies("1.0.0", "=1.0.0"), "1.0.0 = 1.0.0")
	check(VersionCheck.satisfies("1.0.0", ""), "leere Anforderung")
	check(not VersionCheck.satisfies("1.0.0", "~1.0.0"), "unbekannter Operator ~")


func test_pruefen() -> void:
	var res := VersionCheck.check("Modul beispiel", "0.9.0", ">=1.0.0")
	check_eq(res.code, CommandResult.INCOMPATIBLE, "code incompatible bei fehlgeschlagener Prüfung")
	check(res.message.contains("Modul beispiel 0.9.0 erfüllt >=1.0.0 nicht"), "falsche Meldung")

	var res2 := VersionCheck.check("Modul beispiel", "1.0.0", ">=1.0.0")
	check(res2.is_ok(), "is_ok() wahr bei erfolgreicher Prüfung")
