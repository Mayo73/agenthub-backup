class_name PlayerCell
extends Node2D
## Die Zelle des Spielers. Bewegung in CellMotion, Darstellung als Platzhalter mit _draw().

const COLOR := Color(0.5, 0.88, 0.82)
const MOUTH_COLOR := Color(0.1, 0.3, 0.3)

var motion := CellMotion.new()
var radius := 12.0
var input_enabled := true
var diet := Diet.PFLANZENFRESSER
var build := CellBuild.starter(Diet.PFLANZENFRESSER)
var stage := 0
var look := CellLook.new()
var time := 0.0 ## Laufzeit für Animationen in Sekunden.
var flash := HitFlash.new()


func _physics_process(delta: float) -> void:
	if not input_enabled:
		drive(delta, Vector2.ZERO)
		return
	var mouse_held := Input.is_action_pressed("schwimmen")
	drive(delta, PlayerInput.wish(Controls.key_vector(), mouse_held, get_global_mouse_position(), global_position))


## Bewegt die Zelle um einen Zeitschritt und überträgt Lage und Ausrichtung auf den Node.
func drive(delta: float, wish: Vector2) -> void:
	time += delta
	flash.tick(delta)
	motion.step(delta, wish)
	position = motion.position
	rotation = motion.heading
	queue_redraw()


func mouth_point() -> Vector2:
	return MouthContact.mouth_point(motion.position, motion.heading, radius)


## Passt Größe und Tempo an den Größenabschnitt an (0 bis 4).
func set_stage(p_stage: int) -> void:
	stage = p_stage
	refresh()


## Übernimmt einen neuen Aufbau (z. B. nach dem Zelleditor).
func set_build(p_build: CellBuild) -> void:
	build = p_build
	refresh()


## Übernimmt ein neues Aussehen (Farbe, Muster, Streckung), z. B. nach dem Zelleditor.
func set_look(p_look: CellLook) -> void:
	look = p_look
	queue_redraw()


## Rechnet Größe, Tempo, Wendigkeit und Ernährung aus Größenabschnitt und Aufbau neu aus.
func refresh() -> void:
	radius = CellProgress.radius_for_stage(stage)
	motion.max_speed = CellStats.max_speed(build, stage)
	motion.turn_rate = CellStats.turn_rate(build)
	var d := CellStats.diet(build)
	if d != "":
		diet = d
	queue_redraw()


## Linienzug einer Geißel in Pixeln relativ zur Zellmitte, passend zur aktuellen Zeit.
func flagellum_points(part: Dictionary) -> PackedVector2Array:
	return PartAnimation.place_points(PartAnimation.flagellum(time), part, radius)


func _draw() -> void:
	for part in build.parts:
		if PartCatalog.category_of(part["id"]) == "antrieb":
			if part["id"] == "geissel":
				draw_polyline(flagellum_points(part), PartLooks.color(part["id"]), maxf(1.5, radius * 0.1))
			else:
				draw_colored_polygon(PartLooks.placed(part, radius), PartLooks.color(part["id"]))
	CellPainter.draw_cell(self, Vector2.ZERO, look, radius, time)
	if flash.is_active():
		draw_circle(Vector2.ZERO, radius * 1.05, flash.overlay_color())
	for part in build.parts:
		var category := PartCatalog.category_of(part["id"])
		if category == "auge":
			draw_eye(part)
		elif category != "antrieb":
			draw_colored_polygon(PartLooks.placed(part, radius), PartLooks.color(part["id"]))


## Auge mit Pupille in Schwimmrichtung (+x), blinzelt ab und zu; das Stielauge mit Stiel.
func draw_eye(part: Dictionary) -> void:
	var pos: Vector2 = part["pos"]
	var center := EyeLook.eye_center(part, radius)
	var eye_r := EyeLook.eye_radius(part["id"], radius)
	if part["id"] == "stielauge":
		draw_line(pos * radius, center, look.color.darkened(0.3), maxf(1.0, radius * 0.06))
	draw_set_transform(center, 0.0, Vector2(1.0, eye_openness(part)))
	draw_circle(Vector2.ZERO, eye_r, Color.WHITE)
	draw_circle(EyeLook.pupil_offset(Vector2.RIGHT, eye_r), eye_r * 0.5, Color(0.05, 0.05, 0.1))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Wie weit ein Auge gerade offen ist; jedes Auge blinzelt etwas versetzt.
func eye_openness(part: Dictionary) -> float:
	var pos: Vector2 = part["pos"]
	return EyeLook.openness(time, pos.y)
