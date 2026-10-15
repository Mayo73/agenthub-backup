extends Node2D
## Zeichnet die Strecke. Liegt unter "World" und zeichnet in Weltkoordinaten (von oben);
## die isometrische Schräge entsteht durch die Transformation von "World".

const SMOOTH_STEPS := 10
const CURB_WIDTH := 14.0
const CURB_DASH := 40.0
const START_CELL := 20.0

## Kontrollpunkte der Mittellinie (geschlossen). Werden zu einer runden Linie geglättet.
@export var control_points := PackedVector2Array([
	Vector2(0, 0), Vector2(1400, 0), Vector2(2000, 200), Vector2(2300, 700),
	Vector2(2150, 1300), Vector2(1650, 1550), Vector2(1150, 1350), Vector2(750, 1600),
	Vector2(200, 1650), Vector2(-450, 1400), Vector2(-700, 850), Vector2(-600, 350),
	Vector2(-350, 80),
])
@export var width := 280.0
@export var road_color := Color(0.25, 0.26, 0.29)
@export var grass_color := Color(0.16, 0.36, 0.2)
@export var curb_colors: Array[Color] = [Color(0.85, 0.16, 0.14), Color(0.95, 0.95, 0.95)]

var path: TrackPath


func _ready() -> void:
	path = TrackPath.new(TrackPath.smooth_closed(control_points, SMOOTH_STEPS), width)
	queue_redraw()


func _draw() -> void:
	if path == null:
		return
	_fill(path.outline(width * 0.5), road_color)
	_fill(path.outline(-width * 0.5), grass_color)
	_draw_curb(path.outline(width * 0.5 + CURB_WIDTH * 0.5))
	_draw_curb(path.outline(-width * 0.5 - CURB_WIDTH * 0.5))
	_draw_start_line()


func _fill(polygon: PackedVector2Array, color: Color) -> void:
	if polygon.size() >= 3:
		draw_colored_polygon(polygon, color)


## Rot-weiße Randsteine entlang einer geschlossenen Linie.
func _draw_curb(line: PackedVector2Array) -> void:
	var travelled := 0.0
	for i in line.size():
		var a := line[i]
		var b := line[(i + 1) % line.size()]
		draw_line(a, b, curb_colors[int(travelled / CURB_DASH) % 2], CURB_WIDTH)
		travelled += a.distance_to(b)


## Schachbrett-Startlinie quer zur Fahrtrichtung.
func _draw_start_line() -> void:
	var start := path.start_position()
	var forward := Vector2.from_angle(path.start_heading())
	var side := forward.rotated(PI / 2.0)
	for row in 2:
		for i in int(width / START_CELL):
			var corner := start + side * (-width * 0.5 + i * START_CELL) + forward * (row * START_CELL)
			var color := Color.WHITE if (i + row) % 2 == 0 else Color.BLACK
			draw_colored_polygon(PackedVector2Array([
				corner, corner + side * START_CELL,
				corner + side * START_CELL + forward * START_CELL, corner + forward * START_CELL,
			]), color)
