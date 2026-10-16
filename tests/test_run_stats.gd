extends "res://tests/base_test.gd"
## Tests für RunStats (Entwicklungsrückblick)

var s: RunStats


func setup() -> void:
	s = RunStats.new()


func test_zeit() -> void:
	s.tick(100.0)
	s.tick(25.5)
	check_eq(s.time_text(), "2:05", "125.5 Sekunden → 2:05")
	check_eq(RunStats.new().time_text(), "0:00", "Frisches Objekt → 0:00")


func test_hauptnahrung() -> void:
	check_eq(s.main_diet(), "", "Leerer Verlauf → leer")
	s.record_stage("pflanzenfresser")
	s.record_stage("pflanzenfresser")
	s.record_stage("allesfresser")
	check_eq(s.main_diet(), "pflanzenfresser", "2x pflanzen > 1x alles")
	s.record_stage("allesfresser")
	check_eq(s.main_diet(), "allesfresser", "Bei Gleichstand gewinnt zuletzt gleichgezogener")


func test_zeilen() -> void:
	s.food_eaten = 12
	s.cells_defeated = 3
	s.tick(61.0)
	var lines := s.summary_lines()
	check_eq(lines.size(), 5, "Genau 5 Zeilen")
	check_eq(lines[0], "Spielzeit: 1:01", "Zeile 0 ist Spielzeit")
	check_eq(lines[1], "Nahrung gefressen: 12", "Zeile 1 ist Nahrung")
	check_eq(lines[2], "Zellen besiegt: 3", "Zeile 2 ist Zellen besiegt")


func test_speichern() -> void:
	s.deaths = 2
	s.editor_visits = 4
	s.record_stage("fleischfresser")
	s.tick(10.0)
	var t := RunStats.from_dict(s.to_dict())
	check_eq(t.deaths, 2, "deaths gespeichert")
	check_eq(t.editor_visits, 4, "editor_visits gespeichert")
	check_eq(t.play_time, 10.0, "play_time gespeichert")
	check_eq(t.diet_history.size(), 1, "diet_history Länge")
	check_eq(t.diet_history[0], "fleischfresser", "diet_history Inhalt")


func test_kaputte_werte() -> void:
	var t := RunStats.from_dict({"deaths": -3, "play_time": -1.0})
	check_eq(t.deaths, 0, "Negativer deaths auf 0 begrenzt")
	check_eq(t.play_time, 0.0, "Negatives play_time auf 0.0 begrenzt")
	check_eq(t.food_eaten, 0, "Fehlendes food_eaten ist 0")


func test_aus_json() -> void:
	s.record_stage("allesfresser")
	var d: Dictionary = JSON.parse_string(JSON.stringify(s.to_dict()))
	var t := RunStats.from_dict(d)
	check_eq(t.diet_history.size(), 1, "diet_history aus JSON gelesen")
	check_eq(t.main_diet(), "allesfresser", "Hauptnahrung aus JSON")
