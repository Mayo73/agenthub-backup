extends "res://tests/base_test.gd"

var m: CellMotion

func setup() -> void:
	m = CellMotion.new()


func test_beschleunigen() -> void:
	m.step(0.1, Vector2.RIGHT)
	check_eq(m.velocity.x, 60.0, "velocity.x nach Beschleunigung")
	check_eq(m.position.x, 6.0, "position.x nach Beschleunigung")
	check_eq(m.heading, 0.0, "heading bleibt 0.0 bei Bewegung nach rechts")


func test_hoechsttempo() -> void:
	for i in range(20):
		m.step(0.1, Vector2.RIGHT)
	check_eq(m.speed(), 220.0, "speed erreicht max_speed")


func test_ausgleiten() -> void:
	for i in range(20):
		m.step(0.1, Vector2.RIGHT)
	m.step(0.1, Vector2.ZERO)
	check_eq(m.speed(), 165.0, "speed nach einmaligem Ausgleiten")


func test_wenden_begrenzt() -> void:
	m.step(0.1, Vector2.UP)
	check_eq(m.heading, -0.6, "heading nach erstem Schritt")
	for i in range(9):
		m.step(0.1, Vector2.UP)
	check_eq(m.heading, -PI / 2, "heading nach 10 Schritten erreicht -PI/2")


func test_lange_eingabe_normalisiert() -> void:
	m.step(0.1, Vector2(2, 0))
	check_eq(m.velocity.x, 60.0, "velocity.x bei Eingabe > 1 wird normalisiert")


func test_rueckstoss() -> void:
	m.knockback(Vector2(0, 2), 100.0)
	check_eq(m.velocity, Vector2(0, 100.0), "Rückstoß in positiver y-Richtung")
	m.knockback(Vector2.ZERO, 100.0)
	check_eq(m.velocity, Vector2(0, 100.0), "kein Rückstoß bei Vektor ZERO")
