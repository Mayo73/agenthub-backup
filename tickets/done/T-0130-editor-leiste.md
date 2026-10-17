---
id: T-0130
title: Bedienleiste des Zelleditors (CellEditorPanel)
project: zellenphase
priority: 3
after: T-0122
---
## Ziel
Die Leiste des Zelleditors: links Knöpfe für alle freigeschalteten Teile (Name und Kosten), rechts DNA, Kosten der Änderung, Fähigkeitsvorschau und die Knöpfe „Bestätigen“ und „Abbrechen“. Bestätigen ist gesperrt, wenn die DNA nicht reicht oder kein Maul eingebaut ist.

## Dateien
- `scripts/cell_editor_panel.gd`: neu
- `tests/test_cell_editor_panel.gd`: neu

## Akzeptanzkriterien
`scripts/cell_editor_panel.gd` genau so:
```gdscript
class_name CellEditorPanel
extends CanvasLayer
## Bedienleiste des Zelleditors: Teile-Auswahl, DNA, Kosten, Fähigkeitsvorschau, Bestätigen und Abbrechen.

signal part_selected(id: String)
signal confirm_pressed
signal cancel_pressed

var session: EditorSession
var progress: CellProgress
var stage := 0
var selected_id := ""
var palette: VBoxContainer
var info: VBoxContainer
## Teil-ID -> Button
var part_buttons := {}
var dna_label: Label
var cost_label: Label
var preview_label: Label
var confirm_button: Button
var cancel_button: Button


func _init() -> void:
	layer = 5
	palette = VBoxContainer.new()
	palette.name = "Palette"
	palette.position = Vector2(24, 24)
	add_child(palette)
	info = VBoxContainer.new()
	info.name = "Info"
	info.position = Vector2(1520, 24)
	info.add_theme_constant_override("separation", 10)
	add_child(info)
	dna_label = _label()
	cost_label = _label()
	preview_label = _label()
	confirm_button = Button.new()
	confirm_button.text = "Bestätigen"
	confirm_button.custom_minimum_size = Vector2(360, 52)
	info.add_child(confirm_button)
	cancel_button = Button.new()
	cancel_button.text = "Abbrechen"
	cancel_button.custom_minimum_size = Vector2(360, 52)
	info.add_child(cancel_button)
	confirm_button.pressed.connect(func() -> void: confirm_pressed.emit())
	cancel_button.pressed.connect(func() -> void: cancel_pressed.emit())


func _label() -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", 22)
	info.add_child(l)
	return l


## Baut die Teile-Knöpfe für alle freigeschalteten Teile und zeigt die Werte.
func setup(p_session: EditorSession, p_progress: CellProgress, p_stage: int) -> void:
	session = p_session
	progress = p_progress
	stage = p_stage
	selected_id = ""
	for child in palette.get_children():
		palette.remove_child(child)
		child.queue_free()
	part_buttons.clear()
	for id in PartCatalog.ids():
		if session.unlocks.is_unlocked(id):
			var b := Button.new()
			b.text = "%s (%d)" % [PartCatalog.name_of(id), PartCatalog.cost_of(id)]
			b.toggle_mode = true
			b.custom_minimum_size = Vector2(260, 44)
			b.pressed.connect(select.bind(id))
			palette.add_child(b)
			part_buttons[id] = b
	refresh()


## Wählt das Teil, das beim nächsten Klick in die Zelle eingebaut wird.
func select(id: String) -> void:
	selected_id = id
	for key in part_buttons:
		var b: Button = part_buttons[key]
		b.set_pressed_no_signal(key == id)
	part_selected.emit(id)


## Aktualisiert DNA, Kosten, Vorschau und ob Bestätigen möglich ist.
func refresh() -> void:
	dna_label.text = "DNA: %d" % progress.dna
	var c := session.cost()
	if c >= 0:
		cost_label.text = "Kosten: %d DNA" % c
	else:
		cost_label.text = "Rückerstattung: %d DNA" % -c
	preview_label.text = "\n".join(PackedStringArray(EditorPreview.lines(session.original, session.working, stage)))
	confirm_button.disabled = not session.can_confirm(progress.dna)
```

## Tests
`tests/test_cell_editor_panel.gd` mit `extends "res://tests/base_test.gd"`, `var panel: CellEditorPanel`, `var session: EditorSession`, `var progress: CellProgress`; `setup()`: `panel = CellEditorPanel.new()`, `session = EditorSession.new(CellBuild.starter(Diet.PFLANZENFRESSER), PartUnlocks.new())`, `progress = CellProgress.new()`, `progress.eat(20)`, `panel.setup(session, progress, 0)`; `teardown()`: `panel.free()`.
- `test_knoepfe`: `panel.part_buttons.size()` ist 3; `panel.part_buttons["kiefer"].text` ist `"Kiefer (10)"`; `panel.part_buttons.has("geissel")` falsch
- `test_werte`: `panel.dna_label.text` ist `"DNA: 20"`; `panel.cost_label.text` ist `"Kosten: 0 DNA"`; `panel.confirm_button.disabled` falsch; `panel.preview_label.text.contains("Pflanzenfresser")` wahr
- `test_einbau`: `session.place("kiefer", Vector2(0.9, 0.3))`, `panel.refresh()` → `panel.cost_label.text` ist `"Kosten: 10 DNA"`; `panel.preview_label.text.contains("Allesfresser")` wahr
- `test_rueckerstattung`: `session.working.remove_part(1)`, `panel.refresh()` → `panel.cost_label.text` ist `"Rückerstattung: 5 DNA"`
- `test_zu_teuer`: `progress.dna = 5`, `session.place("kiefer", Vector2(0.9, 0.3))`, `panel.refresh()` → `panel.confirm_button.disabled` wahr
- `test_auswahl`: `var got: Array = []`, `panel.part_selected.connect(func(id: String) -> void: got.append(id))`, `panel.select("kiefer")` → `panel.selected_id` ist `"kiefer"`, `panel.part_buttons["kiefer"].button_pressed` wahr, `panel.part_buttons["knopfauge"].button_pressed` falsch, `got.size()` ist 1

Review (16.10.2026): gemergt.
