extends "res://tests/base_test.gd"

var impulse: ImpulseResolve

func setup() -> void:
	impulse = ImpulseResolve.new()

func test_gleiche_massen_elastisch() -> void:
	var result := impulse.resolve(Vector2(1, 0), 1.0, Vector2(-1, 0), 1.0, Vector2(1, 0), 1.0)
	check_eq(result[0], Vector2(-1, 0), "Körper 1 sollte umkehren")
	check_eq(result[1], Vector2(1, 0), "Körper 2 sollte umkehren")

func test_unelastisch() -> void:
	var result := impulse.resolve(Vector2(2, 0), 1.0, Vector2.ZERO, 1.0, Vector2(1, 0), 0.0)
	check_eq(result[0], Vector2(1, 0), "Körper 1 sollte mittlere Geschwindigkeit haben")
	check_eq(result[1], Vector2(1, 0), "Körper 2 sollte mittlere Geschwindigkeit haben")

func test_statische_wand() -> void:
	var result := impulse.resolve(Vector2(0, 5), 2.0, Vector2.ZERO, 0.0, Vector2(0, 1), 0.5)
	check_eq(result[0], Vector2(0, -2.5), "Körper sollte mit Restitution reflektieren")
	check_eq(result[1], Vector2.ZERO, "Wand bleibt unbewegt")

func test_trennen() -> void:
	var result := impulse.resolve(Vector2(-1, 0), 1.0, Vector2(1, 0), 1.0, Vector2(1, 0), 1.0)
	check_eq(result[0], Vector2(-1, 0), "Körper 1 sollte unverändert bleiben")
	check_eq(result[1], Vector2(1, 0), "Körper 2 sollte unverändert bleiben")

func test_3d() -> void:
	var result := impulse.resolve_3d(Vector3(0, -4, 0), 1.0, Vector3.ZERO, 0.0, Vector3(0, -1, 0), 1.0)
	check_eq(result[0], Vector3(0, 4, 0), "Körper sollte in 3D umkehren")
