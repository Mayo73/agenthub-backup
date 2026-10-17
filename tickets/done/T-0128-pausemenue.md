---
id: T-0128
title: Pausemenü (PauseMenu)
project: zellenphase
priority: 3
---
## Ziel
Mit Esc öffnet sich ein Pausemenü mit „Weiter“, „Einstellungen“, „Hauptmenü“ und „Beenden“. Diese Klasse baut nur die Oberfläche und meldet Klicks per Signal; der Einbau in `main.gd` folgt später.

## Dateien
- `scripts/pause_menu.gd`: neu
- `tests/test_pause_menu.gd`: neu

## Akzeptanzkriterien
`scripts/pause_menu.gd` genau so:
```gdscript
class_name PauseMenu
extends CanvasLayer
## Pausemenü. Nur Darstellung und Signale; main.gd hält das Spiel an.

signal resume
signal open_settings
signal to_main_menu
signal quit_game

var box: VBoxContainer
var resume_button: Button
var settings_button: Button
var main_menu_button: Button
var quit_button: Button


func _init() -> void:
	layer = 9
	process_mode = Node.PROCESS_MODE_ALWAYS
	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.color = Color(0, 0, 0, 0.6)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	box = VBoxContainer.new()
	box.name = "Box"
	box.position = Vector2(760, 320)
	box.add_theme_constant_override("separation", 16)
	add_child(box)
	var title := Label.new()
	title.name = "Title"
	title.text = "Pause"
	title.add_theme_font_size_override("font_size", 48)
	box.add_child(title)
	resume_button = _button("Weiter")
	settings_button = _button("Einstellungen")
	main_menu_button = _button("Hauptmenü")
	quit_button = _button("Beenden")
	resume_button.pressed.connect(func() -> void: resume.emit())
	settings_button.pressed.connect(func() -> void: open_settings.emit())
	main_menu_button.pressed.connect(func() -> void: to_main_menu.emit())
	quit_button.pressed.connect(func() -> void: quit_game.emit())
	visible = false


func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(400, 56)
	b.add_theme_font_size_override("font_size", 26)
	box.add_child(b)
	return b


func open() -> void:
	visible = true


func close() -> void:
	visible = false
```

## Tests
`tests/test_pause_menu.gd` mit `extends "res://tests/base_test.gd"`, `var menu: PauseMenu`; `setup()`: `menu = PauseMenu.new()`; `teardown()`: `menu.free()`. Signale mit einem Lambda empfangen, das an ein lokales `var got: Array = []` anhängt.
- `test_start_verborgen`: `menu.visible` falsch; `menu.process_mode == Node.PROCESS_MODE_ALWAYS` wahr; `menu.box.get_child_count()` ist 5
- `test_oeffnen_schliessen`: `menu.open()` → `menu.visible` wahr; `menu.close()` → falsch
- `test_signale`: alle vier Signale verbinden (jedes hängt einen anderen Text an), dann `resume_button`, `settings_button`, `main_menu_button`, `quit_button` nacheinander mit `pressed.emit()` → `got.size()` ist 4
- `test_texte`: `menu.resume_button.text` ist `"Weiter"`; `menu.main_menu_button.text` ist `"Hauptmenü"`

Review (16.10.2026): gemergt.
