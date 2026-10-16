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
