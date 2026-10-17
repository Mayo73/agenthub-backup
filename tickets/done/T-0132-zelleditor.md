---
id: T-0132
title: Zelleditor zusammensetzen (CellEditor)
project: zellenphase
priority: 3
after: T-0123, T-0130, T-0131
---
## Ziel
Der Zelleditor verbindet Bedienleiste (`CellEditorPanel`), Zellansicht (`CellEditorCanvas`) und Verlauf (`EditorHistory`). Dazu kommen Knöpfe für Rückgängig, Wiederholen und Symmetrie sowie Strg+Z und Strg+Y. Bestätigen verrechnet die DNA und meldet den neuen Aufbau, Abbrechen den alten.

## Dateien
- `scripts/cell_editor.gd`: neu
- `tests/test_cell_editor.gd`: neu

## Akzeptanzkriterien
`scripts/cell_editor.gd` genau so:
```gdscript
class_name CellEditor
extends Node
## Zelleditor: verbindet Bedienleiste, Zellansicht und Verlauf. main.gd öffnet ihn nach dem Partnerfund.

## Neuer Aufbau nach Bestätigen, unveränderter Aufbau nach Abbrechen.
signal finished(build: CellBuild)

var session: EditorSession
var history := EditorHistory.new()
var progress: CellProgress
var confirmed := false
var panel: CellEditorPanel
var view_layer: CanvasLayer
var canvas: CellEditorCanvas
var tools: HBoxContainer
var undo_button: Button
var redo_button: Button
var symmetry_button: CheckButton


func _init() -> void:
	view_layer = CanvasLayer.new()
	view_layer.name = "View"
	view_layer.layer = 4
	add_child(view_layer)
	var background := ColorRect.new()
	background.color = Color("#0B2B3D")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view_layer.add_child(background)
	canvas = CellEditorCanvas.new()
	canvas.name = "Canvas"
	view_layer.add_child(canvas)
	panel = CellEditorPanel.new()
	panel.name = "Panel"
	add_child(panel)
	tools = HBoxContainer.new()
	tools.name = "Tools"
	tools.position = Vector2(24, 990)
	panel.add_child(tools)
	undo_button = Button.new()
	undo_button.text = "Rückgängig"
	tools.add_child(undo_button)
	redo_button = Button.new()
	redo_button.text = "Wiederholen"
	tools.add_child(redo_button)
	symmetry_button = CheckButton.new()
	symmetry_button.text = "Symmetrie"
	symmetry_button.button_pressed = true
	tools.add_child(symmetry_button)
	undo_button.pressed.connect(undo)
	redo_button.pressed.connect(redo)
	symmetry_button.toggled.connect(func(on: bool) -> void: canvas.symmetry = on)
	panel.part_selected.connect(func(id: String) -> void: canvas.place_id = id)
	panel.confirm_pressed.connect(confirm)
	panel.cancel_pressed.connect(cancel)
	canvas.changed.connect(_on_changed)


func open(build: CellBuild, unlocks: PartUnlocks, p_progress: CellProgress, stage: int) -> void:
	session = EditorSession.new(build, unlocks)
	progress = p_progress
	confirmed = false
	history.clear()
	panel.setup(session, progress, stage)
	canvas.setup(session, history)
	_update_buttons()


func _on_changed() -> void:
	panel.refresh()
	_update_buttons()


func _update_buttons() -> void:
	undo_button.disabled = not history.can_undo()
	redo_button.disabled = not history.can_redo()


func undo() -> void:
	var b := history.undo(session.working)
	if b != null:
		_show_build(b)


func redo() -> void:
	var b := history.redo(session.working)
	if b != null:
		_show_build(b)


func _show_build(b: CellBuild) -> void:
	session.working = b
	canvas.selected = -1
	canvas.queue_redraw()
	_on_changed()


## Verrechnet die DNA und meldet den neuen Aufbau; tut nichts, wenn es nicht geht.
func confirm() -> void:
	var b := session.confirm(progress)
	if b == null:
		return
	confirmed = true
	finished.emit(b)


func cancel() -> void:
	confirmed = false
	finished.emit(session.cancel())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.ctrl_pressed:
		if event.physical_keycode == KEY_Z:
			undo()
		elif event.physical_keycode == KEY_Y:
			redo()
```

## Tests
`tests/test_cell_editor.gd` mit `extends "res://tests/base_test.gd"`, `var editor: CellEditor`, `var unlocks: PartUnlocks`, `var progress: CellProgress`, `var start: CellBuild`; `setup()`: `editor = CellEditor.new()`, `unlocks = PartUnlocks.new()`, `unlocks.unlock("geissel")`, `progress = CellProgress.new()`, `progress.eat(30)`, `start = CellBuild.starter(Diet.PFLANZENFRESSER)`, `editor.open(start, unlocks, progress, 0)`; `teardown()`: `editor.free()`.
Hilfsfunktion in der Testdatei (nicht `test_` benennen): `func _place_geissel() -> void:` mit `editor.panel.select("geissel")` und `editor.canvas.click(Vector2(752, 696))` (baut zwei gespiegelte Geißeln ein, Kosten 30).
- `test_auswahl_geht_an_ansicht`: `editor.panel.select("geissel")` → `editor.canvas.place_id` ist `"geissel"`
- `test_einbau_zeigt_kosten`: `_place_geissel()` → `editor.panel.cost_label.text` ist `"Kosten: 30 DNA"`; `editor.undo_button.disabled` falsch; `editor.redo_button.disabled` wahr
- `test_rueckgaengig_wiederholen`: `_place_geissel()`, `editor.undo()` → `editor.session.working.parts.size()` ist 2, `editor.panel.cost_label.text` ist `"Kosten: 0 DNA"`, `editor.redo_button.disabled` falsch; `editor.redo()` → `editor.session.working.parts.size()` ist 4
- `test_bestaetigen`: `var got: Array = []`, `editor.finished.connect(func(b: CellBuild) -> void: got.append(b))`, `_place_geissel()`, `editor.confirm()` → `got.size()` ist 1, `got[0].parts.size()` ist 4, `progress.dna` ist 0, `editor.confirmed` wahr
- `test_zu_teuer`: wie oben verbinden; `progress.dna = 10`, `_place_geissel()`, `editor.confirm()` → `got.size()` ist 0, `progress.dna` ist 10
- `test_abbrechen`: wie oben verbinden; `_place_geissel()`, `editor.cancel()` → `got.size()` ist 1, `got[0] == start` wahr, `progress.dna` ist 30, `editor.confirmed` falsch
- `test_symmetrie_schalter`: `editor.symmetry_button.button_pressed = false` → `editor.canvas.symmetry` falsch

Review (16.10.2026): fehlgeschlagen nur am Stapel-Konflikt mit agent/T-0131 (Agent lief nicht). Vorgänger jetzt alle auf main, unverändert zurück nach todo.

Review (16.10.2026): gemergt.
