---
id: T-0133
title: Farbe, Muster und Körperform im Zelleditor
project: zellenphase
priority: 3
after: T-0132, T-0116
---
## Ziel
Im Zelleditor lassen sich Farbe (sechs Vorgaben), Muster und Streckung des Zellkörpers ändern (Lastenheft: „Körperform, Farbe und Muster bearbeiten“). Der Editor arbeitet auf einer Kopie des `CellLook`; die Zellansicht zeichnet den Körper mit dem Umriss und der Farbe aus diesem `CellLook`.

## Dateien
- `scripts/cell_editor.gd`
- `scripts/cell_editor_canvas.gd`
- `tests/test_cell_editor_look.gd`: neu

## Akzeptanzkriterien
- `scripts/cell_editor_canvas.gd`:
  - neue Variable unter `var dragging := false`: `var look: CellLook` mit Kommentar `## Aussehen des Körpers; ohne look wird ein Kreis gezeichnet.`
  - in `_draw()` die Zeile `draw_circle(CENTER, SCALE, BODY_COLOR)` ersetzen durch:
```gdscript
	if look != null:
		var outline := PackedVector2Array()
		for p in look.outline(SCALE):
			outline.append(CENTER + p)
		draw_colored_polygon(outline, look.color)
	else:
		draw_circle(CENTER, SCALE, BODY_COLOR)
```
- `scripts/cell_editor.gd`:
  - neue Konstante oben unter dem Signal: `const COLORS := [Color("#7FE0D0"), Color("#6CCB5F"), Color("#E0C060"), Color("#D98FE0"), Color("#E07F7F"), Color("#7FA8E0")]`
  - neue Variablen unter `var symmetry_button: CheckButton`:
```gdscript
var look: CellLook
var look_box: VBoxContainer
var color_buttons: Array[Button] = []
var pattern_option: OptionButton
var stretch_slider: HSlider
```
  - am Ende von `_init()`:
```gdscript
	look_box = VBoxContainer.new()
	look_box.name = "Look"
	look_box.position = Vector2(24, 720)
	panel.add_child(look_box)
	var title := Label.new()
	title.text = "Aussehen"
	look_box.add_child(title)
	var row := HBoxContainer.new()
	look_box.add_child(row)
	for c in COLORS:
		var b := Button.new()
		b.custom_minimum_size = Vector2(40, 40)
		b.modulate = c
		b.pressed.connect(set_color.bind(c))
		row.add_child(b)
		color_buttons.append(b)
	pattern_option = OptionButton.new()
	for p in CellLook.PATTERNS:
		pattern_option.add_item(str(p).capitalize())
	look_box.add_child(pattern_option)
	stretch_slider = HSlider.new()
	stretch_slider.min_value = CellLook.MIN_STRETCH
	stretch_slider.max_value = CellLook.MAX_STRETCH
	stretch_slider.step = 0.05
	stretch_slider.value = 1.0
	stretch_slider.custom_minimum_size = Vector2(260, 32)
	look_box.add_child(stretch_slider)
	pattern_option.item_selected.connect(set_pattern_index)
	stretch_slider.value_changed.connect(set_stretch)
```
  - neue Funktionen am Ende:
```gdscript
## Der Editor arbeitet auf einer Kopie; main.gd übernimmt look nach dem Bestätigen.
func set_look(l: CellLook) -> void:
	look = l.copy()
	canvas.look = look
	pattern_option.select(CellLook.PATTERNS.find(look.pattern))
	stretch_slider.set_value_no_signal(look.stretch)
	canvas.queue_redraw()


func set_color(c: Color) -> void:
	if look == null:
		return
	look.color = c
	canvas.queue_redraw()


func set_pattern_index(i: int) -> void:
	if look == null:
		return
	look.set_pattern(CellLook.PATTERNS[i])
	canvas.queue_redraw()


func set_stretch(s: float) -> void:
	if look == null:
		return
	look.set_stretch(s)
	canvas.queue_redraw()
```
- Sonst nichts an beiden Dateien ändern.

## Tests
`tests/test_cell_editor_look.gd` mit `extends "res://tests/base_test.gd"`, `var editor: CellEditor`, `var original: CellLook`; `setup()`: `editor = CellEditor.new()`, `editor.open(CellBuild.starter(Diet.PFLANZENFRESSER), PartUnlocks.new(), CellProgress.new(), 0)`, `original = CellLook.new()`, `editor.set_look(original)`; `teardown()`: `editor.free()`.
- `test_kopie`: `editor.set_color(Color.RED)` → `editor.look.color.is_equal_approx(Color.RED)` wahr; `original.color.is_equal_approx(CellLook.DEFAULT_COLOR)` wahr; `editor.canvas.look == editor.look` wahr
- `test_farbknoepfe`: `editor.color_buttons.size()` ist 6; `editor.color_buttons[1].pressed.emit()` → `editor.look.color.is_equal_approx(CellEditor.COLORS[1])` wahr
- `test_muster`: `editor.pattern_option.item_count` ist 4; `editor.pattern_option.item_selected.emit(2)` → `editor.look.pattern` ist `"streifen"`
- `test_streckung`: `editor.stretch_slider.value = 1.4` → `editor.look.stretch` ist 1.4; `editor.set_stretch(3.0)` → `editor.look.stretch` ist 1.5
- `test_ohne_aussehen`: `var e := CellEditor.new()`, `e.set_color(Color.RED)` → `e.look == null` wahr; danach `e.free()`

Review (16.10.2026): gemergt.
