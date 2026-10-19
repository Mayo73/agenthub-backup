extends "res://tests/base_test.gd"

var projectile: Projectile2D
var walls: Array[Rect2]

func setup() -> void:
	projectile = Projectile2D.new()
	walls = [Rect2(10, -50, 0.05, 100)]  # Wand bei x=10, 5cm dick


func test_lebensdauer() -> void:
	var leer: Array[Rect2] = []
	projectile.lifetime = 0.5
	projectile.gravity = 0  # keine Schwerkraft für diesen Test
	var hits_count := projectile.run(1.0, leer)
	check(not projectile.alive, "Projektil soll nach Lebensdauer nicht mehr alive sein")
	check(hits_count == 0, "Keine Treffer bei leerer Wandliste")
	check(projectile.hits.size() == 0, "hits-Array soll leer sein")


func test_entfernen() -> void:
	projectile.position = Vector2(0, 0)
	projectile.velocity = Vector2(200, 0)
	projectile.gravity = 0
	projectile.reaction = Projectile2D.REMOVE
	var hits_count := projectile.run(1.0, walls)
	check(hits_count == 1, "Sollte 1 Treffer registriert haben")
	check(not projectile.alive, "Projektil soll nach REMOVE nicht mehr alive sein")
	check(abs(projectile.position.x - 10) < 0.1, "position.x soll ungefähr 10 sein")


func test_stoppen() -> void:
	projectile.position = Vector2(0, 0)
	projectile.velocity = Vector2(200, 0)
	projectile.gravity = 0
	projectile.reaction = Projectile2D.STOP
	var hits_count := projectile.run(1.0, walls)
	check(projectile.stopped, "stopped soll wahr sein nach STOP-Reaktion")
	check(projectile.velocity == Vector2.ZERO, "velocity soll Vector2.ZERO sein")
	check(hits_count == 1, "Sollte 1 Treffer registriert haben")


func test_rueckprall() -> void:
	projectile.position = Vector2(0, 0)
	projectile.velocity = Vector2(200, 0)
	projectile.gravity = 0
	projectile.reaction = Projectile2D.BOUNCE
	projectile.restitution = 0.5
	# So lange step aufrufen bis Rückprall stattfindet
	var max_steps := 120
	var hit_occurred := false
	for i in range(max_steps):
		var result := projectile.step(1.0 / 120.0, walls)
		if not result.is_empty():
			hit_occurred = true
			break
	check(hit_occurred, "Rückprall soll eintreten innerhalb von 120 Schritten")
	# velocity.x sollte ungefähr -100 sein (200 * -0.5 durch Bounce bei Wandnormal (-1,0))
	check(abs(projectile.velocity.x + 100) < 10, "velocity.x soll ungefähr -100 sein")


func test_normale() -> void:
	projectile.position = Vector2(0, 0)
	projectile.velocity = Vector2(200, 0)
	projectile.gravity = 0
	projectile.reaction = Projectile2D.REMOVE
	var steps := roundi(1.0 / (1.0 / 120.0))
	for _i in steps:
		var result := projectile.step(1.0 / 120.0, walls)
		if not result.is_empty():
			break
	check(projectile.hits.size() > 0, "Sollte mindestens einen Treffer haben")
	check(projectile.hits[0]["normal"] == Vector2(-1, 0), "Normale von links sollte (-1, 0) sein")
