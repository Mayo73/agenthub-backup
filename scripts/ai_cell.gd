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


## Übernimmt die Werte der Art und setzt die Zelle an pos.
func setup(id: String, pos: Vector2) -> void:
	var d := SpeciesCatalog.data(id)
	species_id = id
	radius = SpeciesCatalog.radius_of(id)
	diet = d["diet"]
	damage = d["damage"]
	color = d["color"]
	motion.max_speed = d["speed"]
	motion.acceleration = d["speed"] * 2.5
	motion.position = pos
	position = pos
	health = CellHealth.new(d["hp"])


func think(others: Array, food_pos: Variant) -> void:
	wish = brain.decide(motion.position, radius, diet, others, food_pos)


func drive(delta: float) -> void:
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


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)
	draw_circle(Vector2(radius * 0.8, 0), radius * 0.22, color.darkened(0.5))
