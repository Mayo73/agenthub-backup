extends "res://tests/base_test.gd"

func setup() -> void:
	pass

func test_treffer() -> void:
	## Wand bei x=5, 5 cm dick (x-Größe 0.05)
	var wand: AABB = AABB(Vector3(5, -10, -10), Vector3(0.05, 20, 20))

	## Strecke von (0,0,0) nach (10,0,0) trifft die Wand bei t=0.5
	var result: Dictionary = SweepHit3D.segment_aabb(Vector3.ZERO, Vector3(10, 0, 0), wand)
	check(not result.is_empty(), "Treffer erkannt")
	check(abs(result["t"] - 0.5) < 0.001, "t ist ungefähr 0.5")
	check_eq(result["normal"], Vector3(-1, 0, 0), "normal ist (-1,0,0)")
	check(abs(result["position"].x - 5.0) < 0.001, "position.x ist ungefähr 5.0")

func test_daneben() -> void:
	## Wand bei x=5, 5 cm dick
	var wand: AABB = AABB(Vector3(5, -10, -10), Vector3(0.05, 20, 20))

	## Strecke von (0,20,0) nach (10,20,0) geht daneben (y=20 ist außerhalb des Walls von y=-10 bis y=10)
	var result: Dictionary = SweepHit3D.segment_aabb(Vector3(0, 20, 0), Vector3(10, 20, 0), wand)
	check(result.is_empty(), "kein Treffer bei Strecke daneben")

func test_zu_kurz() -> void:
	## Wand bei x=5, 5 cm dick
	var wand: AABB = AABB(Vector3(5, -10, -10), Vector3(0.05, 20, 20))

	## Strecke von (0,0,0) nach (4,0,0) endet vor der Wand
	var result: Dictionary = SweepHit3D.segment_aabb(Vector3.ZERO, Vector3(4, 0, 0), wand)
	check(result.is_empty(), "kein Treffer bei zu kurzer Strecke")

func test_schnell() -> void:
	## Wand bei x=5, 5 cm dick
	var wand: AABB = AABB(Vector3(5, -10, -10), Vector3(0.05, 20, 20))

	## 100 Strecken mit Länge 50 (von (-20,y,0) nach (30,y,0)), y = -9.0 + i * 0.18
	var treffer_zahl: int = 0
	for i in range(100):
		var from_pos: Vector3 = Vector3(-20, -9.0 + i * 0.18, 0)
		var to_pos: Vector3 = Vector3(30, -9.0 + i * 0.18, 0)
		var result: Dictionary = SweepHit3D.segment_aabb(from_pos, to_pos, wand)
		if not result.is_empty():
			treffer_zahl += 1

	check_eq(treffer_zahl, 100, "alle 100 Strecken treffen die Wand")

func test_erster() -> void:
	## Zwei Wände bei x=5 und x=3 (gleiche Maße)
	var wand_vorne: AABB = AABB(Vector3(5, -10, -10), Vector3(0.05, 20, 20))
	var wand_hinten: AABB = AABB(Vector3(3, -10, -10), Vector3(0.05, 20, 20))

	## Strecke von (0,0,0) nach (10,0,0) trifft zuerst die hintere Wand bei x=3
	var boxes: Array[AABB] = [wand_vorne, wand_hinten]
	var result: Dictionary = SweepHit3D.first_hit(Vector3.ZERO, Vector3(10, 0, 0), boxes)
	check(not result.is_empty(), "Treffer erkannt")
	check_eq(result["index"], 1, "index ist 1 (hintere Wand)")

func test_abprall() -> void:
	## Reflexion bei einem senkrechten Aufprall mit Restitution 0.5
	var velocity: Vector3 = Vector3(10, 0, 0)
	var normal: Vector3 = Vector3(-1, 0, 0)
	var restitution: float = 0.5

	var reflected: Vector3 = SweepHit3D.reflect(velocity, normal, restitution)
	check_eq(reflected, Vector3(-5, 0, 0), "reflected ist (-5,0,0)")
