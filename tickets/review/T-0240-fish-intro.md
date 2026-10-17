---
id: T-0240
title: Fischphase – Übergangsbildschirm „Aus deiner Zelle wird ein Fisch“ (FishIntro)
project: zellenphase
priority: 3
after: T-0238
---
## Ziel
Damit der Übergang nachvollziehbar ist, zeigt die Fischphase zu Beginn einen Bildschirm: was aus der Zelle geworden ist (Ernährung, Schwanzflosse, Brustflossen …). Er schließt sich nach 8 Sekunden oder mit „Losschwimmen“. Eingebaut wird er in T-0248.

## Dateien
- `scripts/fish_intro.gd` – neu
- `tests/test_fish_intro.gd` – neu

## Akzeptanzkriterien
`scripts/fish_intro.gd` genau so:
```gdscript
class_name FishIntro
extends CanvasLayer
## Übergangsbildschirm zu Beginn der Fischphase: zeigt, was aus der Zelle geworden ist.
## Schließt sich nach DURATION Sekunden oder mit dem Knopf "Losschwimmen".

signal closed

const DURATION := 8.0

var title_label: Label
var lines_box: VBoxContainer
var go_button: Button
var time_left := 0.0


func _init() -> void:
	layer = 15
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.02, 0.12, 0.18, 0.85)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var box := VBoxContainer.new()
	box.name = "Box"
	box.position = Vector2(560, 220)
	box.add_theme_constant_override("separation", 14)
	add_child(box)
	title_label = Label.new()
	title_label.name = "Title"
	title_label.text = "Aus deiner Zelle wird ein Fisch"
	title_label.add_theme_font_size_override("font_size", 48)
	box.add_child(title_label)
	lines_box = VBoxContainer.new()
	lines_box.name = "Lines"
	box.add_child(lines_box)
	go_button = Button.new()
	go_button.name = "Go"
	go_button.text = "Losschwimmen"
	go_button.custom_minimum_size = Vector2(400, 56)
	box.add_child(go_button)
	go_button.pressed.connect(close)
	visible = false


## Zeigt die Zeilen von FishStart.summary_lines(fish) und startet die Anzeigedauer.
func open(fish: FishBuild) -> void:
	for child in lines_box.get_children():
		lines_box.remove_child(child)
		child.free()
	for line in FishStart.summary_lines(fish):
		var l := Label.new()
		l.text = line
		l.add_theme_font_size_override("font_size", 28)
		lines_box.add_child(l)
	time_left = DURATION
	visible = true


func close() -> void:
	if not visible:
		return
	visible = false
	time_left = 0.0
	closed.emit()


func tick(delta: float) -> void:
	if not visible:
		return
	time_left -= delta
	if time_left <= 0.0:
		close()


func _process(delta: float) -> void:
	tick(delta)
```
- Keine andere Datei ändern.

## Tests
`tests/test_fish_intro.gd` mit `extends "res://tests/base_test.gd"`, `var intro: FishIntro`; `setup()`: `intro = FishIntro.new()`; `teardown()`: `intro.free()`:
- `test_neu`: `intro.visible` falsch; `intro.title_label.text` ist `"Aus deiner Zelle wird ein Fisch"`
- `test_oeffnen`: `var f := FishBuild.new()`, `f.upgrade("schwanz")`; `intro.open(f)` → `intro.visible` wahr; `intro.lines_box.get_child_count()` ist 2; `(intro.lines_box.get_child(1) as Label).text` ist `"Schwanzflosse: Stufe 1"`
- `test_zweimal_oeffnen`: `intro.open(FishBuild.new())`; `intro.open(FishBuild.new())` → `intro.lines_box.get_child_count()` ist 1
- `test_zeit`: `var got := [0]`; `intro.closed.connect(func() -> void: got[0] += 1)`; `intro.open(FishBuild.new())`; `intro.tick(7.0)` → `intro.visible` wahr; `intro.tick(1.5)` → `intro.visible` falsch; `got[0]` ist 1; noch einmal `intro.tick(1.0)` → `got[0]` ist 1
- `test_knopf`: `intro.open(FishBuild.new())`; `intro.go_button.pressed.emit()` → `intro.visible` falsch
