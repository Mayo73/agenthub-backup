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


func _physics_process(delta: float) -> void:
	if not input_enabled:
		drive(delta, Vector2.ZERO)
		return
	var mouse_held := Input.is_action_pressed("schwimmen")
	drive(delta, PlayerInput.wish(Controls.key_vector(), mouse_held, get_global_mouse_position(), global_position))


## Bewegt die Zelle um einen Zeitschritt und überträgt Lage und Ausrichtung auf den Node.
func drive(delta: float, wish: Vector2) -> void:
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


func _draw() -> void:
	for part in build.parts:
		if PartCatalog.category_of(part["id"]) == "antrieb":
			draw_colored_polygon(PartShapes.placed(part, radius), PartShapes.color_of(part["id"]))
	draw_colored_polygon(look.outline(radius), look.color)
	for part in build.parts:
		if PartCatalog.category_of(part["id"]) != "antrieb":
			draw_colored_polygon(PartShapes.placed(part, radius), PartShapes.color_of(part["id"]))
