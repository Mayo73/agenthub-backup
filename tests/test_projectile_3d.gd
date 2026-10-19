extends "res://tests/base_test.gd"

var projectile: Projectile3D
var wand: AABB

func setup() -> void:
	projectile = Projectile3D.new()
	# Wand als AABB bei x ≈ 5, y von -10 bis 10, z von -10 bis 10
	wand = AABB(Vector3(5, -10, -10), Vector3(0.05, 20, 20))

func test_stoppt() -> void:
	projectile.velocity = Vector3(100, 0, 0)
	projectile.on_hit = Projectile3D.STOP
	var hits_count: int = projectile.run(1.0, [wand])
	check_eq(hits_count, 1, "ein Treffer erwartet")
	check(projectile.stopped, "stopped sollte wahr sein")
	check(absf(projectile.position.x - 5.0) < 0.1, "position.x sollte bei ca. 5.0 liegen")

func test_entfernt() -> void:
	projectile.velocity = Vector3(100, 0, 0)
	projectile.on_hit = Projectile3D.REMOVE
	var hits_count: int = projectile.run(1.0, [wand])
	check_eq(hits_count, 1, "ein Treffer erwartet")
	check(not projectile.alive, "alive sollte falsch sein nach REMOVE")

func test_abprall() -> void:
	projectile.velocity = Vector3(100, 0, 0)
	projectile.on_hit = Projectile3D.BOUNCE
	projectile.restitution = 0.5
	var hits_count: int = projectile.run(0.2, [wand])
	check_eq(hits_count, 1, "ein Treffer erwartet")
	## Nach dem Bounce sollte velocity.x negativ und ungefähr -50 sein (100 * -0.5)
	check(projectile.velocity.x < 0, "velocity.x sollte negativ nach BOUNCE")
	check(absf(projectile.velocity.x + 50.0) < 10.0, "velocity.x sollte bei ca. -50 liegen")

func test_lebensdauer() -> void:
	projectile.lifetime = 0.5
	projectile.velocity = Vector3(1, 0, 0)
	var hits_count: int = projectile.run(1.0, [])
	check(not projectile.alive, "alive sollte falsch sein nach Ablauf der Lebensdauer")
	check(absf(projectile.age - 0.5) < 0.1, "age sollte bei ca. 0.5 liegen")
	check_eq(hits_count, 0, "keine Treffer erwartet")

func test_schwerkraft() -> void:
	projectile.gravity = 9.81
	projectile.velocity = Vector3.ZERO
	projectile.run(1.0, [])
	## position.y sollte bei -4.9 liegen (s = 0.5 * g * t^2 = 0.5 * 9.81 * 1^2 ≈ 4.905)
	check(absf(projectile.position.y + 4.9) < 0.1, "position.y sollte bei ca. -4.9 liegen")
