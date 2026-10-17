class_name PlayerCell
extends Node2D
## Die Zelle des Spielers. Bewegung in CellMotion, Darstellung als Platzhalter mit _draw().

const COLOR := Color(0.5, 0.88, 0.82)
const MOUTH_COLOR := Color(0.1, 0.3, 0.3)
const CHEW_TIME := 0.3
const PULSE_TIME := 0.6

var motion := CellMotion.new()
var radius := 12.0
var input_enabled := true
var diet := Diet.PFLANZENFRESSER
var build := CellBuild.starter(Diet.PFLANZENFRESSER)
var stage := 0
var look := CellLook.new()
var time := 0.0 ## Laufzeit für Animationen in Sekunden.
## Restzeit der Kaubewegung in Sekunden.
var chew_left := 0.0
## Restzeit des Wachstumspulses in Sekunden.
var pulse_left := 0.0
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
	chew_left = maxf(0.0, chew_left - delta)
	flash.tick(delta)
	motion.step(delta, wish)
	position = motion.position
	rotation = motion.heading
	queue_redraw()
	pulse_left = maxf(0.0, pulse_left - delta)
	scale = Vector2.ONE * pulse_scale()


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


## Wimpern als Linienzüge in Pixeln relativ zur Zellmitte.
func cilia_lines(part: Dictionary) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	for line in PartAnimation.cilia(time):
		out.append(PartLooks.place(line, part, radius))
	return out


## Umriss der Düse in Pixeln relativ zur Zellmitte; pulsiert im Takt.
func jet_points(part: Dictionary) -> PackedVector2Array:
	var s := PartAnimation.jet_scale(time)
	var pts := PackedVector2Array()
	for p in PartLooks.shape("duese"):
		pts.append(p * s)
	return PartLooks.place(pts, part, radius)


func _draw() -> void:
	for part in build.parts:
		if PartCatalog.category_of(part["id"]) == "antrieb":
			if part["id"] == "geissel":
				draw_polyline(flagellum_points(part), PartLooks.color(part["id"]), maxf(1.5, radius * 0.1))
			elif part["id"] == "wimpern":
				for line in cilia_lines(part):
					draw_polyline(line, PartLooks.color(part["id"]), maxf(1.0, radius * 0.05))
			elif part["id"] == "duese":
				draw_colored_polygon(jet_points(part), PartLooks.color(part["id"]))
			else:
				if PartLooks.outline(part["id"]).a > 0.0:
					draw_polyline(PartLooks.closed(PartLooks.placed(part, radius)), PartLooks.outline(part["id"]), maxf(1.0, radius * 0.06))
				draw_colored_polygon(PartLooks.placed(part, radius), PartLooks.color(part["id"]))
	CellPainter.draw_cell(self, Vector2.ZERO, look, radius, time)
	if flash.is_active():
		draw_circle(Vector2.ZERO, radius * 1.05, flash.overlay_color())
	for part in build.parts:
		var category := PartCatalog.category_of(part["id"])
		if category == "auge":
			draw_eye(part)
		elif category == "maul":
			draw_colored_polygon(mouth_points(part), PartLooks.color(part["id"]))
		elif category != "antrieb":
			if PartLooks.outline(part["id"]).a > 0.0:
				draw_polyline(PartLooks.closed(PartLooks.placed(part, radius)), PartLooks.outline(part["id"]), maxf(1.0, radius * 0.06))
			if part["id"] == "elektro":
				draw_circle((part["pos"] as Vector2) * radius, radius * 0.35, Color(0.5, 0.85, 1.0, glow_alpha()))
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


## Startet eine Kaubewegung (beim Fressen oder Beißen).
func bite() -> void:
	chew_left = CHEW_TIME


## Öffnung des Mauls: 1 = normal, bis 1,5 mitten in der Kaubewegung.
func mouth_open() -> float:
	return 1.0 + 0.5 * sin(PI * chew_left / CHEW_TIME)


## Umriss des Mauls in Pixeln relativ zur Zellmitte, quer zur Blickrichtung um mouth_open() geweitet.
func mouth_points(part: Dictionary) -> PackedVector2Array:
	var open := mouth_open()
	var pts := PackedVector2Array()
	for p in PartLooks.shape(part["id"]):
		pts.append(Vector2(p.x, p.y * open))
	return PartLooks.place(pts, part, radius)


## Startet den Wachstumspuls.
func pulse() -> void:
	pulse_left = PULSE_TIME


## Größenfaktor der Darstellung: steigt während des Pulses bis 1,25 und fällt zurück auf 1.
func pulse_scale() -> float:
	return 1.0 + 0.25 * sin(PI * pulse_left / PULSE_TIME)


## Deckkraft des Scheins um das Elektroorgan; flackert leicht.
func glow_alpha() -> float:
	return 0.3 + 0.15 * sin(time * 9.0)
