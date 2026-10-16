class_name CellEditorCanvas
extends Node2D
## Große Ansicht der Zelle im Zelleditor: Teile einbauen, auswählen, verschieben, drehen und entfernen.
## Die Methoden sind ohne Maus testbar; _unhandled_input ruft sie nur auf.

signal changed

const CENTER := Vector2(960, 540)
const SCALE := 260.0
const BODY_COLOR := Color(0.5, 0.88, 0.82)
const SELECT_COLOR := Color(1.0, 0.9, 0.3)

var session: EditorSession
var history: EditorHistory
## Teil-ID, die beim nächsten Klick eingebaut wird; "" = Klick wählt ein Teil aus.
var place_id := ""
var selected := -1
var symmetry := true
var dragging := false
## Aussehen des Körpers; ohne look wird ein Kreis gezeichnet.
var look: CellLook


func setup(p_session: EditorSession, p_history: EditorHistory) -> void:
	session = p_session
	history = p_history
	selected = -1
	queue_redraw()


func to_local_pos(screen: Vector2) -> Vector2:
	return EditorPlacement.clamp_to_body(EditorPlacement.screen_to_local(screen, CENTER, SCALE))


## Klick: mit place_id einbauen (gespiegelt, wenn symmetry), sonst das Teil unter dem Klick auswählen.
func click(screen: Vector2) -> void:
	var local := to_local_pos(screen)
	if place_id == "":
		selected = EditorPlacement.part_at(session.working, local)
		queue_redraw()
		return
	var before := session.working.copy()
	var placed := 0
	if symmetry:
		placed = EditorSymmetry.place_mirrored(session, place_id, local).size()
	elif session.place(place_id, local) >= 0:
		placed = 1
	if placed > 0:
		history.record(before)
		selected = session.working.parts.size() - placed
		changed.emit()
	queue_redraw()


## Beginnt das Verschieben des ausgewählten Teils (ein Verlaufseintrag pro Zug).
func begin_drag() -> void:
	if selected < 0:
		return
	history.record(session.working)
	dragging = true


func drag_to(screen: Vector2) -> void:
	if selected < 0:
		return
	session.working.move_part(selected, to_local_pos(screen))
	changed.emit()
	queue_redraw()


func end_drag() -> void:
	dragging = false


## Dreht das ausgewählte Teil um step und rastet auf EditorPlacement.ANGLE_STEP ein.
func rotate_selected(step: float) -> void:
	if selected < 0:
		return
	history.record(session.working)
	var angle: float = session.working.parts[selected]["angle"]
	session.working.rotate_part(selected, EditorPlacement.snap_angle(angle + step))
	changed.emit()
	queue_redraw()


func remove_selected() -> void:
	if selected < 0:
		return
	history.record(session.working)
	session.working.remove_part(selected)
	selected = -1
	changed.emit()
	queue_redraw()


func _draw() -> void:
	if session == null:
		return
	if look != null:
		var outline := PackedVector2Array()
		for p in look.outline(SCALE):
			outline.append(CENTER + p)
		draw_colored_polygon(outline, look.color)
	else:
		draw_circle(CENTER, SCALE, BODY_COLOR)
	for i in session.working.parts.size():
		var part: Dictionary = session.working.parts[i]
		var points := PackedVector2Array()
		for p in PartShapes.placed(part, SCALE):
			points.append(CENTER + p)
		var color := SELECT_COLOR if i == selected else PartShapes.color_of(part["id"])
		draw_colored_polygon(points, color)


func _unhandled_input(event: InputEvent) -> void:
	if session == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var was_placing := place_id != ""
			click(event.position)
			if not was_placing:
				begin_drag()
		else:
			end_drag()
	elif event is InputEventMouseMotion and dragging:
		drag_to(event.position)
	elif event is InputEventKey and event.pressed:
		if event.physical_keycode == KEY_Q:
			rotate_selected(-EditorPlacement.ANGLE_STEP)
		elif event.physical_keycode == KEY_E:
			rotate_selected(EditorPlacement.ANGLE_STEP)
		elif event.physical_keycode == KEY_DELETE or event.physical_keycode == KEY_BACKSPACE:
			remove_selected()
