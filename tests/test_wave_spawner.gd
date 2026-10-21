extends "res://tests/base_test.gd"


func test_ungueltig() -> void:
	var s := WaveSpawner.new()
	check_eq(s.add_wave("", 3, 1.0).code, "invalid_argument", "leere Art")
	check_eq(s.add_wave("schleim", 0, 1.0).code, "invalid_argument", "Anzahl 0")


func test_eine_welle() -> void:
	var s := WaveSpawner.new()
	s.add_wave("schleim", 3, 1.0)
	s.start()
	check_eq(s.run(0.5).size(), 1, "erster Gegner sofort")
	check_eq(s.run(2.0).size(), 2, "zwei weitere in 2 Sekunden")
	check(s.finished(), "Wellen fertig")


func test_zwei_wellen() -> void:
	var s := WaveSpawner.new()
	s.add_wave("schleim", 2, 0.5)
	s.add_wave("fledermaus", 1, 0.0, 3.0)
	s.start()
	var erste: Array[String] = s.run(2.0)
	check_eq(erste, ["schleim", "schleim"] as Array[String], "zwei Schleime")
	var zweite: Array[String] = s.run(3.0)
	check(zweite.has("fledermaus"), "Fledermaus erscheint bei etwa 4 s")
	check(s.finished(), "Wellen fertig")


func test_speichern() -> void:
	var s := WaveSpawner.new()
	s.add_wave("schleim", 2, 0.5)
	s.add_wave("fledermaus", 1, 0.0, 3.0)
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(s.to_dict()))
	var loaded := WaveSpawner.from_dict(parsed)
	check_eq(loaded.waves.size(), 2, "zwei Wellen")
	var count: int = loaded.waves[0]["count"]
	check_eq(count, 2, "Anzahl der ersten Welle")
