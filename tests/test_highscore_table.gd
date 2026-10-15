extends "res://tests/base_test.gd"

const TEST_PATH := "user://test_bestenliste.json"

var table: HighscoreTable


func setup() -> void:
	table = HighscoreTable.new()


func teardown() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))


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


func test_speichern_und_laden() -> void:
	table.submit("hafen", 95.5, 800)
	table.submit("altstadt", 120.25, 1500)
	check(table.save(TEST_PATH), "speichern klappt")
	var loaded := HighscoreTable.load_from(TEST_PATH)
	check_eq(loaded.best_time("hafen"), 95.5, "best_time(hafen) nach laden ist 95.5")
	check_eq(loaded.best_points("hafen"), 800, "best_points(hafen) nach laden ist 800")
	check_eq(loaded.best_time("altstadt"), 120.25, "best_time(altstadt) nach laden ist 120.25")
	check_eq(loaded.best_points("altstadt"), 1500, "best_points(altstadt) nach laden ist 1500")


func test_fehlende_datei() -> void:
	check_eq(HighscoreTable.load_from("user://gibt_es_nicht.json").best_time("hafen"), -1.0, "leere Tabelle bei fehlender Datei")


func test_kaputte_datei() -> void:
	var f := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	f.store_string("kein json")
	f.close()
	check_eq(HighscoreTable.load_from(TEST_PATH).best_points("hafen"), 0, "leere Tabelle bei kaputter JSON-Datei")
