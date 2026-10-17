---
id: T-0148
title: Abschlussbildschirm mit Entwicklungsrückblick (EndScreen)
project: zellenphase
priority: 3
after: T-0126
---
## Ziel
Ein Abschlussbildschirm beendet den Durchlauf und zeigt einen Entwicklungsrückblick: Spielzeit, gefressene Nahrung, besiegte Zellen, Tode, Editorbesuche und Hauptnahrung (Lastenheft „Vollständiger Durchlauf“, Soll „Entwicklungsrückblick“).

## Dateien
- `scripts/end_screen.gd`: neu
- `tests/test_end_screen.gd`: neu

## Akzeptanzkriterien
`scripts/end_screen.gd` genau so:
```gdscript
class_name EndScreen
extends CanvasLayer
## Abschlussbildschirm der Zellenphase mit Entwicklungsrückblick. Nur Darstellung und Signale.

signal to_main_menu
signal quit_game

var box: VBoxContainer
var title_label: Label
var lines_box: VBoxContainer
var menu_button: Button
var quit_button: Button


func _init() -> void:
	layer = 12
	process_mode = Node.PROCESS_MODE_ALWAYS
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.04, 0.17, 0.24, 0.97)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	box = VBoxContainer.new()
	box.name = "Box"
	box.position = Vector2(660, 200)
	box.add_theme_constant_override("separation", 14)
	add_child(box)
	title_label = Label.new()
	title_label.name = "Title"
	title_label.text = "Die Zellenphase ist geschafft!"
	title_label.add_theme_font_size_override("font_size", 48)
	box.add_child(title_label)
	lines_box = VBoxContainer.new()
	lines_box.name = "Lines"
	box.add_child(lines_box)
	menu_button = Button.new()
	menu_button.text = "Hauptmenü"
	menu_button.custom_minimum_size = Vector2(400, 56)
	box.add_child(menu_button)
	quit_button = Button.new()
	quit_button.text = "Beenden"
	quit_button.custom_minimum_size = Vector2(400, 56)
	box.add_child(quit_button)
	menu_button.pressed.connect(func() -> void: to_main_menu.emit())
	quit_button.pressed.connect(func() -> void: quit_game.emit())
	visible = false


## Zeigt den Rückblick: die Zeilen von stats.summary_lines() und die Hauptnahrung.
func show_stats(stats: RunStats) -> void:
	for child in lines_box.get_children():
		lines_box.remove_child(child)
		child.free()
	var lines := stats.summary_lines()
	lines.append("Hauptnahrung: " + diet_name(stats.main_diet()))
	for line in lines:
		var l := Label.new()
		l.text = line
		l.add_theme_font_size_override("font_size", 28)
		lines_box.add_child(l)
	visible = true


## Deutscher Name einer Ernährungsart.
static func diet_name(diet: String) -> String:
	if diet == Diet.PFLANZENFRESSER:
		return "Pflanzenfresser"
	if diet == Diet.FLEISCHFRESSER:
		return "Fleischfresser"
	if diet == Diet.ALLESFRESSER:
		return "Allesfresser"
	return "unbekannt"
```

## Tests
`tests/test_end_screen.gd` mit `extends "res://tests/base_test.gd"`, `var screen: EndScreen`; `setup()`: `screen = EndScreen.new()`; `teardown()`: `screen.free()`.
- `test_verborgen`: `screen.visible` falsch; `screen.process_mode == Node.PROCESS_MODE_ALWAYS` wahr
- `test_rueckblick`: `var s := RunStats.new()`, `s.food_eaten = 5`, `s.record_stage(Diet.FLEISCHFRESSER)`, `screen.show_stats(s)` → `screen.visible` wahr; `screen.lines_box.get_child_count()` ist 6; `(screen.lines_box.get_child(1) as Label).text` ist `"Nahrung gefressen: 5"`; `(screen.lines_box.get_child(5) as Label).text` ist `"Hauptnahrung: Fleischfresser"`
- `test_zweimal`: `screen.show_stats(RunStats.new())` zweimal → `screen.lines_box.get_child_count()` ist 6; `(screen.lines_box.get_child(5) as Label).text` ist `"Hauptnahrung: unbekannt"`
- `test_namen`: `EndScreen.diet_name(Diet.PFLANZENFRESSER)` ist `"Pflanzenfresser"`; `EndScreen.diet_name(Diet.ALLESFRESSER)` ist `"Allesfresser"`; `EndScreen.diet_name("")` ist `"unbekannt"`
- `test_signale`: `var got: Array = []`, beide Signale verbinden (je ein anderer Wert), `screen.menu_button.pressed.emit()`, `screen.quit_button.pressed.emit()` → `got.size()` ist 2

Review (16.10.2026): gemergt.
