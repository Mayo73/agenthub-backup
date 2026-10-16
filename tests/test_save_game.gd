extends "res://tests/base_test.gd"
const PATH := "user://test_spielstand.json"


func teardown() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)


func test_hin_und_zurueck() -> void:
	var p := CellProgress.new()
	p.eat(12)
	var h := CellHealth.new()
	h.damage(30.0)
	var b := CellBuild.starter(Diet.FLEISCHFRESSER)
	b.add_part("geissel", Vector2(-1, 0.25), 0.5)
	var u := PartUnlocks.new()
	u.unlock("geissel")

	check(SaveGame.write_file(PATH, SaveGame.to_dict(p, h, b, u)), "write_file sollte wahr sein")
	var d := SaveGame.read_file(PATH)

	var p2 := CellProgress.new()
	var h2 := CellHealth.new()
	var u2 := PartUnlocks.new()
	check(SaveGame.apply(d, p2, h2, u2), "apply sollte wahr sein")

	check_eq(p2.dna, 12, "dna")
	check_eq(p2.growth, 2, "growth")
	check_eq(p2.stage, 1, "stage")
	check_eq(h2.hp, 70.0, "hp")
	check(u2.is_unlocked("geissel"), "geissel unlocked")
	check_eq(u2.unlocked.size(), 4, "unlocked size")

	var b2 := SaveGame.read_build(d)
	check_eq(b2.parts.size(), 3, "build parts size")
	check_eq(b2.parts[2]["id"], "geissel", "part[2] id")
	check_eq(b2.parts[2]["pos"], Vector2(-1, 0.25), "part[2] pos")
	check_eq(b2.parts[2]["angle"], 0.5, "part[2] angle")
	check_eq(b2.parts[0]["id"], "kiefer", "part[0] id")


func test_fehlende_datei() -> void:
	check(SaveGame.read_file("user://gibtsnicht_123.json").is_empty(), "fehlende Datei sollte leer zurückgeben")


func test_falsche_version() -> void:
	var p := CellProgress.new()
	p.eat(3)
	check(SaveGame.apply({"version": 99, "dna": 50}, p, CellHealth.new(), PartUnlocks.new()) == false, "apply sollte falsch sein")
	check_eq(p.dna, 3, "dna unverändert")


func test_unbekannte_teile_ignoriert() -> void:
	var u := PartUnlocks.new()
	check(SaveGame.apply({"version": 1, "unlocked": ["filtermaul", "gibtsnicht", "filtermaul"]}, CellProgress.new(), CellHealth.new(), u), "apply sollte wahr sein")
	check_eq(u.unlocked.size(), 1, "nur filtermaul unlocked")
