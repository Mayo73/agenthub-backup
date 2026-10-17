---
id: T-0131
title: Zellansicht im Editor (CellEditorCanvas)
project: zellenphase
priority: 3
after: T-0124
---
## Ziel
Die große Ansicht der Zelle im Zelleditor. Ein Klick baut das gewählte Teil ein (mit Symmetrie gespiegelt) oder wählt ein vorhandenes Teil aus; das ausgewählte Teil lässt sich verschieben, drehen (Q/E) und entfernen (Entf). Jede Änderung landet im Verlauf (`EditorHistory`). Die Methoden sind ohne Maus testbar; `_unhandled_input` ruft sie nur auf.

## Dateien
- `scripts/cell_editor_canvas.gd`: neu
- `tests/test_cell_editor_canvas.gd`: neu

## Akzeptanzkriterien
`scripts/cell_editor_canvas.gd` genau so:
```gdscript
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
```

## Tests
`tests/test_cell_editor_canvas.gd` mit `extends "res://tests/base_test.gd"`, `var canvas: CellEditorCanvas`, `var session: EditorSession`, `var history: EditorHistory`; `setup()`: `var u := PartUnlocks.new()`, `u.unlock("geissel")`, `session = EditorSession.new(CellBuild.starter(Diet.PFLANZENFRESSER), u)`, `history = EditorHistory.new()`, `canvas = CellEditorCanvas.new()`, `canvas.setup(session, history)`; `teardown()`: `canvas.free()`.
Hinweis: Der Startaufbau hat das Filtermaul bei (1, 0) (Index 0) und das Knopfauge bei (0.4, 0) (Index 1). Bildschirmpunkt = (960, 540) + Lage × 260.
- `test_einbauen_gespiegelt`: `canvas.place_id = "geissel"`, `canvas.click(Vector2(752, 696))` (Lage (-0.8, 0.6)) → `session.working.parts.size()` ist 4; `(session.working.parts[3]["pos"] as Vector2).is_equal_approx(Vector2(-0.8, -0.6))` wahr; `canvas.selected` ist 2; `history.can_undo()` wahr
- `test_ohne_symmetrie`: `canvas.symmetry = false`, `canvas.place_id = "geissel"`, `canvas.click(Vector2(752, 696))` → `session.working.parts.size()` ist 3; `canvas.selected` ist 2
- `test_gesperrt`: `canvas.place_id = "stachel"`, `canvas.click(Vector2(752, 696))` → `session.working.parts.size()` ist 2; `history.can_undo()` falsch
- `test_auswaehlen`: `canvas.click(Vector2(1064, 540))` → `canvas.selected` ist 1; `canvas.click(Vector2(960, 740))` → `canvas.selected` ist -1
- `test_ziehen_begrenzt`: `canvas.click(Vector2(1064, 540))`, `canvas.begin_drag()`, `canvas.drag_to(Vector2(1480, 540))` → `session.working.parts[1]["pos"]` ist (1, 0); `history.can_undo()` wahr
- `test_drehen`: `canvas.click(Vector2(1064, 540))`, `canvas.rotate_selected(EditorPlacement.ANGLE_STEP)` → `session.working.parts[1]["angle"]` ist `PI / 8`
- `test_entfernen`: `var got: Array = []`, `canvas.changed.connect(func() -> void: got.append(1))`, `canvas.click(Vector2(1064, 540))`, `canvas.remove_selected()` → `session.working.parts.size()` ist 1; `canvas.selected` ist -1; `got.size()` ist 1; `history.undo(session.working).parts.size()` ist 2

Review (16.10.2026): abgelehnt, weil die Klasse als RefCounted ohne Zeichnen und Eingabe gebaut war und eine eigene, mit T-0123 unvereinbare EditorHistory mitbrachte (entstand vor dem Merge von T-0123). Von Claude nach Ticketvorgabe selbst umgesetzt (203 ok).
