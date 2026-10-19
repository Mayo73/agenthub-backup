extends "res://tests/base_test.gd"

var timeline: EvolutionTimeline


func setup() -> void:
	timeline = EvolutionTimeline.new()


func test_hinzufuegen() -> void:
	timeline.add(EvolutionTimeline.START, "Start", Diet.PFLANZENFRESSER, 0.0, Color.WHITE, "zelle")
	timeline.add(EvolutionTimeline.STAGE, "Abschnitt 1", Diet.FLEISCHFRESSER, 60.0, Color.ORANGE, "zelle")

	check_eq(timeline.size(), 2, "size() nach zwei Einträgen")

	var letzter := timeline.last()
	check_eq(letzter["kind"], EvolutionTimeline.STAGE, "last()[\"kind\"] ist der zweite Eintrag")


func test_leer() -> void:
	var letzter := timeline.last()
	check(letzter == {}, "last() ist {} bei leerer Liste")


func test_ernaehrungsfarbe() -> void:
	var pflanzen_color := EvolutionTimeline.diet_color(Diet.PFLANZENFRESSER)
	var fleisch_color := EvolutionTimeline.diet_color(Diet.FLEISCHFRESSER)
	var alles_color := EvolutionTimeline.diet_color(Diet.ALLESFRESSER)
	var unbekannt_color := EvolutionTimeline.diet_color("unbekannt")

	check_eq(pflanzen_color, Color("#6CCB5F"), "pflanzenfresser farbe")
	check_eq(fleisch_color, Color("#D9534F"), "fleischfresser farbe")
	check_eq(alles_color, Color("#9B6CD9"), "allesfresser farbe")
	check_eq(unbekannt_color, Color.GRAY, "unbekannt graue farbe")


func test_zeit() -> void:
	var text1 := EvolutionTimeline.time_text(75.0)
	var text2 := EvolutionTimeline.time_text(5.0)

	check_eq(text1, "1:15", "time_text(75.0)")
	check_eq(text2, "0:05", "time_text(5.0)")


func test_speichern() -> void:
	var farbe := Color(0.5, 0.9, 0.8)
	timeline.add(EvolutionTimeline.START, "Start Test", Diet.ALLESFRESSER, 123.45, farbe, "zelle")

	var dict: Dictionary = timeline.to_dict()
	var json_str: String = JSON.stringify(dict)
	var parsed: Dictionary = JSON.parse_string(json_str)

	var loaded := EvolutionTimeline.from_dict(parsed)

	check_eq(loaded.size(), 1, "eintrag wurde gespeichert")
	check_eq(loaded.last()["kind"], "start", "art stimmt nach laden")
	check_eq(loaded.last()["label"], "Start Test", "beschriftung stimmt nach laden")
	check_eq(loaded.last()["time"], 123.45, "zeit stimmt nach laden")

	var last_color: Color = loaded.last()["color"]
	check(last_color.r >= farbe.r - 0.001 && last_color.r <= farbe.r + 0.001, "rot farbe beim speichern")
	check(last_color.g >= farbe.g - 0.001 && last_color.g <= farbe.g + 0.001, "gruen farbe beim speichern")
	check(last_color.b >= farbe.b - 0.001 && last_color.b <= farbe.b + 0.001, "blau farbe beim speichern")
