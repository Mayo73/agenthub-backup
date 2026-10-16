extends "res://tests/base_test.gd"

var cell: PlayerCell


func setup() -> void:
	cell = PlayerCell.new()


func teardown() -> void:
	cell.free()


func test_schwimmen() -> void:
	cell.drive(0.1, Vector2.RIGHT)
	check_eq(cell.position.x, 6.0, "position x nach Rechtsbewegung")
	check_eq(cell.rotation, 0.0, "rotation nach Rechtsbewegung")


func test_drehen() -> void:
	cell.drive(0.1, Vector2.UP)
	check_eq(cell.rotation, -0.6, "rotation nach Bewegung nach oben")


func test_wachsen() -> void:
	cell.set_stage(2)
	check_eq(cell.radius, 27.0, "cell.radius ist 27.0 nach set_stage(2)")
	check_eq(cell.motion.max_speed, 280.0, "cell.motion.max_speed ist 280.0 nach set_stage(2)")


func test_startaufbau() -> void:
	check_eq(cell.build.mouths().size(), 1, "build.mouths().size() ist 1")
	check_eq(cell.build.mouths()[0], "filtermaul", "build.mouths()[0] ist filtermaul")
	check_eq(cell.stage, 0, "cell.stage ist 0")


func test_aufbau_uebernehmen() -> void:
	var b := CellBuild.starter(Diet.FLEISCHFRESSER)
	b.add_part("geissel", Vector2(-1, 0))
	cell.set_build(b)
	check_eq(cell.diet, Diet.FLEISCHFRESSER, "cell.diet ist FLEISCHFRESSER nach set_build")
	check_eq(cell.motion.max_speed, 280.0, "max_speed ist 280.0 nach set_build")
	check_eq(cell.motion.turn_rate, 6.0, "turn_rate ist 6.0 nach set_build")
	cell.set_stage(1)
	check_eq(cell.motion.max_speed, 310.0, "max_speed ist 310.0 nach set_stage(1)")
	check_eq(cell.radius, 18.0, "radius ist 18.0 nach set_stage(1)")


func test_wimpern_wendiger() -> void:
	var b := CellBuild.starter(Diet.PFLANZENFRESSER)
	b.add_part("wimpern", Vector2(0, 1))
	cell.set_build(b)
	check_eq(cell.motion.turn_rate, 9.0, "turn_rate ist 9.0 mit Wimpern")


func test_ohne_maul_bleibt_ernaehrung() -> void:
	cell.diet = Diet.FLEISCHFRESSER
	cell.set_build(CellBuild.new())
	check_eq(cell.diet, Diet.FLEISCHFRESSER, "cell.diet bleibt FLEISCHFRESSER ohne Maul")


func test_aussehen_start() -> void:
	check(cell.look.color.is_equal_approx(CellLook.DEFAULT_COLOR), "look.color ist DEFAULT_COLOR zu Start")
	check_eq(cell.look.pattern, "keins", "look.pattern ist keins zu Start")


func test_aussehen_setzen() -> void:
	var l := CellLook.new()
	l.set_stretch(1.5)
	cell.set_look(l)
	check(cell.look == l, "cell.look ist gleich nach set_look")
	# Radius 12 * Streckung 1,5 = 18
	check(cell.look.outline(cell.radius)[0].is_equal_approx(Vector2(18, 0)), "outline[0] bei Streckung 1,5")


func test_aussehen_bleibt_beim_wachsen() -> void:
	var l := CellLook.new()
	l.color = Color.RED
	cell.set_look(l)
	cell.set_stage(2)
	check(cell.look.color.is_equal_approx(Color.RED), "look.color bleibt RED nach set_stage(2)")


func test_zeit_startet_bei_null() -> void:
	check_eq(cell.time, 0.0, "cell.time ist 0.0")


func test_zeit_laeuft() -> void:
	cell.drive(0.5, Vector2.ZERO)
	cell.drive(0.25, Vector2.ZERO)
	check_eq(cell.time, 0.75, "cell.time ist 0.75 nach zwei drive()-Aufrufen")


func test_geissel_punkte() -> void:
	var part := {"id": "geissel", "pos": Vector2(-1, 0), "angle": 0.0}
	check_eq(cell.flagellum_points(part).size(), 8, "flagellum_points hat 8 Punkte")
	check(cell.flagellum_points(part)[0].is_equal_approx(Vector2(-cell.radius, 0)), "erster Punkt ist bei -radius")


func test_geissel_bewegt_sich() -> void:
	var part := {"id": "geissel", "pos": Vector2(-1, 0), "angle": 0.0}
	var a := cell.flagellum_points(part)[7]
	cell.drive(0.1, Vector2.ZERO)
	var b := cell.flagellum_points(part)[7]
	check(not a.is_equal_approx(b), "Geißelendpunkt bewegt sich nach drive()")


func test_auge_offen() -> void:
	cell.drive(1.0, Vector2.ZERO)
	check_eq(cell.eye_openness({"id": "knopfauge", "pos": Vector2(0.5, 0.0), "angle": 0.0}), 1.0, "Auge ist offen")


func test_auge_blinzelt() -> void:
	cell.drive(0.05, Vector2.ZERO)
	check_eq(cell.eye_openness({"id": "knopfauge", "pos": Vector2(0.5, 0.0), "angle": 0.0}), 0.1, "Auge blinzelt")


func test_auge_versetzt() -> void:
	cell.drive(0.05, Vector2.ZERO)
	check_eq(cell.eye_openness({"id": "knopfauge", "pos": Vector2(0.5, 1.0), "angle": 0.0}), 1.0, "Auge mit Versetzung ist offen")


func test_wimpern_linien() -> void:
	var part := {"id": "wimpern", "pos": Vector2(-1, 0), "angle": 0.0}
	var lines := cell.cilia_lines(part)
	check_eq(lines.size(), 5, "cilia_lines hat 5 Linien")
	check(lines[0][0].is_equal_approx(Vector2(-cell.radius, -0.25 * cell.radius)), "erste Linie beginnt bei (-radius, -0.25*radius)")


func test_duese_pulsiert() -> void:
	var part := {"id": "duese", "pos": Vector2(-1, 0), "angle": 0.0}
	var a := cell.jet_points(part)[1]
	cell.drive(0.1, Vector2.ZERO)
	var b := cell.jet_points(part)[1]
	check_eq(cell.jet_points(part).size(), 4, "jet_points hat 4 Punkte")
	check(not a.is_equal_approx(b), "Düse pulsiert nach drive()")


func test_maul_ruhig() -> void:
	check_eq(cell.mouth_open(), 1.0, "mouth_open() ist 1.0 in Ruhe")


func test_maul_kaut() -> void:
	cell.bite()
	cell.drive(0.15, Vector2.ZERO)
	check_eq(cell.mouth_open(), 1.5, "mouth_open() ist 1.5 nach bite() + drive(0.15)")
	cell.drive(1.0, Vector2.ZERO)
	check_eq(cell.mouth_open(), 1.0, "mouth_open() ist 1.0 nach Ablauf der Kaubewegung")


func test_maul_form() -> void:
	var part := {"id": "kiefer", "pos": Vector2(1, 0), "angle": 0.0}
	check(cell.mouth_points(part)[1].is_equal_approx(Vector2(1.35 * cell.radius, 0.16 * cell.radius)), "mouth_points[1] ist (1.35r, 0.16r) in Ruhe")
	cell.bite()
	cell.drive(0.15, Vector2.ZERO)
	check(cell.mouth_points(part)[1].is_equal_approx(Vector2(1.35 * cell.radius, 0.24 * cell.radius)), "mouth_points[1] ist (1.35r, 0.24r) während Kaubewegung")
