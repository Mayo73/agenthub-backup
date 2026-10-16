class_name AiCell
extends Node2D
## Eine KI-gesteuerte Zelle. Werte aus dem SpeciesCatalog, Entscheidungen in AiBrain, Bewegung in CellMotion.

var species_id := ""
var motion := CellMotion.new()
var health := CellHealth.new()
var brain := AiBrain.new()
var radius := 12.0
var diet := Diet.PFLANZENFRESSER
var damage := 0.0
var color := Color.WHITE
var wish := Vector2.ZERO
var look := CellLook.new()
var behavior := ""
## Laufzeit für Animationen in Sekunden.
var time := 0.0
var flash := HitFlash.new()


## Übernimmt die Werte der Art und setzt die Zelle an pos.
func setup(id: String, pos: Vector2) -> void:
	var d := SpeciesCatalog.data(id)
	species_id = id
	radius = SpeciesCatalog.radius_of(id)
	diet = d["diet"]
	damage = d["damage"]
	color = d["color"]
	look = SpeciesCatalog.look_of(id)
	behavior = d["behavior"]
	motion.max_speed = d["speed"]
	motion.acceleration = d["speed"] * 2.5
	motion.position = pos
	position = pos
	health = CellHealth.new(d["hp"])


func think(others: Array, food_pos: Variant) -> void:
	wish = brain.decide(motion.position, radius, diet, others, food_pos)


func drive(delta: float) -> void:
	time += delta
	flash.tick(delta)
	motion.step(delta, wish)
	health.tick(delta)
	position = motion.position
	rotation = motion.heading
	queue_redraw()


func _physics_process(delta: float) -> void:
	drive(delta)


func mouth_point() -> Vector2:
	return MouthContact.mouth_point(motion.position, motion.heading, radius)


## Daten für die Entscheidungen anderer Zellen (siehe AiBrain.decide).
func info() -> Dictionary:
	return {"position": motion.position, "radius": radius, "diet": diet}


## Blickrichtung der Pupille in Zellkoordinaten (die Zelle ist um motion.heading gedreht).
func pupil_dir() -> Vector2:
	return wish.rotated(-motion.heading)


## Sichtbare Teile der Art, an die Streckung des Körpers angepasst.
func visible_parts() -> Array:
	return SpeciesParts.placed_parts(species_id, look.stretch)


func _draw() -> void:
	if behavior == "stachel":
		for spike in spike_shapes():
			draw_colored_polygon(spike, color.darkened(0.3))
	for part in visible_parts():
		if part["id"] == "geissel":
			draw_polyline(PartAnimation.place_points(PartAnimation.flagellum(time), part, radius), PartLooks.color("geissel"), maxf(1.5, radius * 0.1))
		elif PartCatalog.category_of(part["id"]) == "antrieb":
			draw_colored_polygon(PartLooks.placed(part, radius), PartLooks.color(part["id"]))
	CellPainter.draw_cell(self, Vector2.ZERO, look, radius, time)
	if flash.is_active():
		draw_circle(Vector2.ZERO, radius * 1.05, flash.overlay_color())
	for part in visible_parts():
		if PartCatalog.category_of(part["id"]) != "antrieb":
			draw_colored_polygon(PartLooks.placed(part, radius), PartLooks.color(part["id"]))


## Acht Stacheln rundum (Dreiecke), Spitzen bei 1,5 Radien.
func spike_shapes() -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	for i in 8:
		var a := TAU * i / 8.0
		var dir := Vector2.from_angle(a)
		var side := dir.orthogonal() * radius * 0.18
		out.append(PackedVector2Array([dir * radius * 0.8 + side, dir * radius * 1.5, dir * radius * 0.8 - side]))
	return out
