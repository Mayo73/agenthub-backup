extends "res://tests/base_test.gd"

var build: CellBuild
var look: CellLook

func setup() -> void:
	build = CellBuild.new()
	look = CellLook.new()

func teardown() -> void:
	FishStart.clear()


func test_teile() -> void:
	build.add_part("geissel", Vector2(-1, 0))
	build.add_part("geissel", Vector2(-1, 0.3))
	build.add_part("wimpern", Vector2(0, 1))
	build.add_part("kiefer", Vector2(1, 0))
	var f := FishStart.from_cell(build, CellLook.new(), Diet.FLEISCHFRESSER)
	check_eq(f.level("schwanz"), 2, "Geißel wird zu Schwanzflosse mit Stufe 2")
	check_eq(f.level("flossen"), 1, "Wimpern werden zu Brustflossen mit Stufe 1")
	check_eq(f.level("kiefer"), 1, "Kiefer bleibt Kiefer mit Stufe 1")
	check_eq(f.level("stacheln"), 0, "Keine Stacheln vorhanden")
	check_eq(f.diet, Diet.FLEISCHFRESSER, "Ernährung wird übernommen")


func test_hoechstens_zwei() -> void:
	build.add_part("stachel", Vector2(1, 0))
	build.add_part("stachel", Vector2(1, 0))
	build.add_part("stachel", Vector2(1, 0))
	build.add_part("stachel", Vector2(1, 0))
	var f := FishStart.from_cell(build, CellLook.new(), Diet.PFLANZENFRESSER)
	check_eq(f.level("stacheln"), 2, "Höchstens zwei Stufen aus Zelle")


func test_farbe() -> void:
	look.color = Color(0.9, 0.2, 0.3)
	var f := FishStart.from_cell(CellBuild.new(), look, Diet.PFLANZENFRESSER)
	check(f.color.is_equal_approx(Color(0.9, 0.2, 0.3)), "Farbe wird übernommen")


func test_unbekannte_teile() -> void:
	build.add_part("gift", Vector2(-1, 0))
	build.add_part("filtermaul", Vector2(1, 0))
	var f := FishStart.from_cell(build, CellLook.new(), Diet.PFLANZENFRESSER)
	check_eq(f.total_levels(), 0, "Unbekannte Teile werden ignoriert")


func test_zeilen() -> void:
	var f := FishBuild.new()
	f.diet = Diet.PFLANZENFRESSER
	f.upgrade("schwanz")
	f.upgrade("schwanz")
	f.upgrade("augen")
	var lines := FishStart.summary_lines(f)
	check_eq(lines.size(), 3, "Drei Zeilen: Ernährung + zwei Bauteile")
	check_eq(lines[0], "Ernährung: Pflanzenfresser", "Erste Zeile zeigt Ernährung")
	check_eq(lines[1], "Schwanzflosse: Stufe 2", "Zweite Zeile zeigt Schwanzflosse")
	check_eq(lines[2], "Augen: Stufe 1", "Dritte Zeile zeigt Augen")


func test_argument() -> void:
	check(FishStart.requested(PackedStringArray(["--fisch"])), "--fisch wird erkannt")
	check(not FishStart.requested(PackedStringArray(["--szene=jagd"])), "Andere Argumente werden ignoriert")


func test_uebergabe() -> void:
	FishStart.pending_build = FishBuild.new()
	FishStart.pending_dna = 40
	FishStart.clear()
	check(FishStart.pending_build == null, "pending_build wird auf null gesetzt")
	check_eq(FishStart.pending_dna, 0, "pending_dna wird auf 0 gesetzt")


func test_fischstand_leeren() -> void:
	FishStart.pending_fish = {"dna": 3}
	FishStart.clear()
	check(FishStart.pending_fish.is_empty(), "pending_fish ist leer nach clear()")
