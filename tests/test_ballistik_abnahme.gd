extends "res://tests/base_test.gd"

# Abnahmekriterium 8: 100 schnelle Schüsse gegen dünne Wände, kein Treffer wird ausgelassen.

const TEMPI: Array[float] = [50.0, 150.0, 300.0, 600.0, 1000.0]
const STAERKEN: Array[float] = [0.01, 0.05, 0.2, 1.0]
const WINKEL: Array[float] = [-40.0, -20.0, 0.0, 20.0, 40.0]


func _schuss(tempo: float, staerke: float, winkel: float) -> Projectile2D:
	var p := Projectile2D.new()
	p.position = Vector2.ZERO
	p.velocity = Vector2.from_angle(deg_to_rad(winkel)) * tempo
	p.gravity = 0.0
	p.reaction = Projectile2D.REMOVE
	p.lifetime = 1.0
	var walls: Array[Rect2] = [Rect2(5.0, -100.0, staerke, 200.0)]
	p.run(1.0, walls)
	return p


func test_hundert_versuche() -> void:
	var versuche := 0
	var fehler: Array[String] = []
	for tempo in TEMPI:
		for staerke in STAERKEN:
			for winkel in WINKEL:
				versuche += 1
				var p := _schuss(tempo, staerke, winkel)
				var name := "v=%s, d=%s, w=%s" % [tempo, staerke, winkel]
				if p.hits.size() != 1:
					fehler.append("%s: %d Treffer" % [name, p.hits.size()])
					continue
				var pos: Vector2 = p.hits[0]["position"]
				var normal: Vector2 = p.hits[0]["normal"]
				if p.alive or absf(pos.x - 5.0) >= 0.001 or normal != Vector2(-1, 0):
					fehler.append("%s: Treffer bei %s, Normale %s" % [name, pos, normal])
	check_eq(versuche, 100, "100 Versuche im Raster")
	check_eq(fehler.size(), 0, "kein ausgelassener oder falscher Treffer: %s" % "; ".join(fehler))


func test_duennste_wand_schnellster_schuss() -> void:
	var p := _schuss(1000.0, 0.01, 0.0)
	check_eq(p.hits.size(), 1, "1000 m/s gegen 1 cm Wand trifft")
	check(not p.alive, "Projektil ist nach dem Treffer entfernt")
