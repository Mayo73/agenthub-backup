extends "res://tests/base_test.gd"

var table: HighscoreTable


func setup() -> void:
	table = HighscoreTable.new()


func test_leer() -> void:
	check_eq(table.best_time("hafen"), -1.0, "best_time von leerer Strecke ist -1.0")
	check_eq(table.best_points("hafen"), 0, "best_points von leerer Strecke ist 0")


func test_erster_eintrag() -> void:
	var r: Dictionary = table.submit("hafen", 95.5, 800)
	check(r["new_time"], "time wird als neuer Rekord erkannt")
	check(r["new_points"], "points werden als neuer Rekord erkannt")
	check_eq(table.best_time("hafen"), 95.5, "best_time wurde korrekt gespeichert")
	check_eq(table.best_points("hafen"), 800, "best_points wurde korrekt gespeichert")


func test_schlechter_bleibt() -> void:
	table.submit("hafen", 95.5, 800)
	var r: Dictionary = table.submit("hafen", 99.0, 700)
	check(not r["new_time"], "schlechtere Zeit wird nicht als Rekord erkannt")
	check(not r["new_points"], "weniger Punkte werden nicht als Rekord erkannt")
	check_eq(table.best_time("hafen"), 95.5, "best_time unverändert (95.5)")
	check_eq(table.best_points("hafen"), 800, "best_points unverändert (800)")


func test_nur_punkte_besser() -> void:
	table.submit("hafen", 95.5, 800)
	var r: Dictionary = table.submit("hafen", 97.0, 900)
	check(not r["new_time"], "schlechtere Zeit ist kein neuer Rekord")
	check(r["new_points"], "höhere Punkte sind ein neuer Rekord")
	check_eq(table.best_time("hafen"), 95.5, "best_time unverändert (95.5)")
	check_eq(table.best_points("hafen"), 900, "best_points auf 900 aktualisiert")


func test_strecken_getrennt() -> void:
	table.submit("hafen", 95.5, 800)
	check_eq(table.best_time("altstadt"), -1.0, "andere Strecke ist noch leer (-1.0)")
