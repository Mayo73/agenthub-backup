extends "res://tests/base_test.gd"

var g: SwipeGesture


func setup() -> void:
	g = SwipeGesture.new()


func test_nach_rechts() -> void:
	g.begin(Vector2(100, 500))
	g.move(Vector2(300, 520))
	check_eq(g.preview(), SwipeGesture.Result.LIKE, "preview nach rechts sollte LIKE sein")
	var result := g.finish()
	check_eq(result, SwipeGesture.Result.LIKE, "finish nach rechts sollte LIKE sein")
	check(not g.active, "active soll nach finish false sein")
	check(g.offset == Vector2.ZERO, "offset soll nach finish null sein")


func test_nach_links() -> void:
	g.begin(Vector2(400, 500))
	g.move(Vector2(200, 500))
	var result := g.finish()
	check_eq(result, SwipeGesture.Result.PASS, "finish nach links sollte PASS sein")


func test_zu_kurz() -> void:
	g.begin(Vector2(100, 500))
	g.move(Vector2(200, 500))
	var result := g.finish()
	check_eq(result, SwipeGesture.Result.NONE, "finish bei zu kurzer Bewegung sollte NONE sein")


func test_eher_senkrecht() -> void:
	g.begin(Vector2(100, 100))
	g.move(Vector2(300, 400))
	var result := g.finish()
	check_eq(result, SwipeGesture.Result.NONE, "finish bei eher senkrechter Bewegung sollte NONE sein")


func test_ohne_beginn() -> void:
	g.move(Vector2(500, 0))
	var result := g.finish()
	check_eq(result, SwipeGesture.Result.NONE, "finish ohne begin sollte NONE sein")


func test_neigung() -> void:
	g.begin(Vector2.ZERO)
	g.move(Vector2(160, 0))
	check_eq(g.tilt(), 0.125, "tilt bei 160 soll 0.125 sein")

	g.move(Vector2(1000, 0))
	check_eq(g.tilt(), 0.25, "tilt bei großer Bewegung soll MAX_TILT sein")

	g.move(Vector2(-320, 0))
	check_eq(g.tilt(), -0.25, "tilt nach links soll negativ sein")


func test_abbrechen() -> void:
	g.begin(Vector2(100, 500))
	g.move(Vector2(1000, 520))
	g.cancel()
	var result := g.finish()
	check_eq(result, SwipeGesture.Result.NONE, "finish nach cancel sollte NONE sein")

func test_stempel_staerke() -> void:
	g.begin(Vector2(100, 600))
	g.move(Vector2(180, 600))
	check_eq(g.stamp_strength(), 0.5, "halbe Mindeststrecke ergibt 0.5")
	check_eq(g.stamp_kind(), SwipeGesture.Result.LIKE, "nach rechts: LIKE")
	g.move(Vector2(-200, 600))
	check_eq(g.stamp_strength(), 1.0, "über der Mindeststrecke höchstens 1.0")
	check_eq(g.stamp_kind(), SwipeGesture.Result.PASS, "nach links: PASS")
	g.finish()
	check_eq(g.stamp_strength(), 0.0, "nach finish 0.0")
	check_eq(g.stamp_kind(), SwipeGesture.Result.NONE, "nach finish NONE")


func test_stempel_ohne_wischen() -> void:
	check_eq(g.stamp_strength(), 0.0, "ohne begin 0.0")
	check_eq(g.stamp_kind(), SwipeGesture.Result.NONE, "ohne begin NONE")