extends "res://tests/base_test.gd"

func test_tasten() -> void:
	check_eq(PlayerInput.wish(Vector2(1, 0), false, Vector2.ZERO, Vector2.ZERO), Vector2(1, 0), "rechts gibt Rechtsvektor")

func test_tasten_schraeg() -> void:
	var result := PlayerInput.wish(Vector2(1, 1), false, Vector2.ZERO, Vector2.ZERO)
	check_eq(result.length(), 1.0, "diagonale Eingabe wird auf Länge 1 normalisiert")

func test_maus() -> void:
	check_eq(PlayerInput.wish(Vector2.ZERO, true, Vector2(100, 0), Vector2.ZERO), Vector2(1, 0), "Maus rechts gibt Rechtsvektor")

func test_maus_relativ_zur_zelle() -> void:
	check_eq(PlayerInput.wish(Vector2.ZERO, true, Vector2(50, 150), Vector2(50, 50)), Vector2(0, 1), "Maus relativ zur Zellenposition")

func test_maus_totzone() -> void:
	check_eq(PlayerInput.wish(Vector2.ZERO, true, Vector2(5, 5), Vector2.ZERO), Vector2.ZERO, "Maus in Totzone gibt Nullvektor")

func test_maus_vor_tasten() -> void:
	check_eq(PlayerInput.wish(Vector2(-1, 0), true, Vector2(0, 100), Vector2.ZERO), Vector2(0, 1), "Maus vor Tasten")

func test_ohne_eingabe() -> void:
	check_eq(PlayerInput.wish(Vector2.ZERO, false, Vector2(100, 0), Vector2.ZERO), Vector2.ZERO, "ohne Maus-Input bleibt Nullvektor")
