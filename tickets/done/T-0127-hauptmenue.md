---
id: T-0127
title: Hauptmenü (MainMenu)
project: zellenphase
priority: 3
---
## Ziel
Deutsches Hauptmenü mit neuer Partie als Pflanzen- oder Fleischfresser, Fortsetzen, Einstellungen und Beenden (Lastenheft „Bedienung und Speicherung“). Diese Klasse baut nur die Oberfläche und meldet Klicks per Signal; der Einbau in `main.gd` folgt in einem späteren Ticket.

## Dateien
- `scripts/main_menu.gd`: neu
- `tests/test_main_menu.gd`: neu

## Akzeptanzkriterien
`scripts/main_menu.gd` genau so:
```gdscript
class_name MainMenu
extends CanvasLayer
## Hauptmenü der Zellenphase. Nur Darstellung und Signale; main.gd entscheidet, was passiert.

signal new_game(diet: String)
signal continue_game
signal open_settings
signal quit_game

var box: VBoxContainer
var title_label: Label
var herbivore_button: Button
var carnivore_button: Button
var continue_button: Button
var settings_button: Button
var quit_button: Button


func _init() -> void:
	layer = 10
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color("#0B2B3D")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	box = VBoxContainer.new()
	box.name = "Box"
	box.position = Vector2(760, 280)
	box.add_theme_constant_override("separation", 16)
	add_child(box)
	title_label = Label.new()
	title_label.name = "Title"
	title_label.text = "Zellenphase"
	title_label.add_theme_font_size_override("font_size", 56)
	box.add_child(title_label)
	herbivore_button = _button("Neue Partie: Pflanzenfresser")
	carnivore_button = _button("Neue Partie: Fleischfresser")
	continue_button = _button("Fortsetzen")
	settings_button = _button("Einstellungen")
	quit_button = _button("Beenden")
	herbivore_button.pressed.connect(func() -> void: new_game.emit(Diet.PFLANZENFRESSER))
	carnivore_button.pressed.connect(func() -> void: new_game.emit(Diet.FLEISCHFRESSER))
	continue_button.pressed.connect(func() -> void: continue_game.emit())
	settings_button.pressed.connect(func() -> void: open_settings.emit())
	quit_button.pressed.connect(func() -> void: quit_game.emit())
	continue_button.disabled = true


func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(400, 56)
	b.add_theme_font_size_override("font_size", 26)
	box.add_child(b)
	return b


## Fortsetzen geht nur mit vorhandenem Spielstand.
func set_can_continue(value: bool) -> void:
	continue_button.disabled = not value
```

## Tests
`tests/test_main_menu.gd` mit `extends "res://tests/base_test.gd"`, `var menu: MainMenu`; `setup()`: `menu = MainMenu.new()`; `teardown()`: `menu.free()`. Signale in den Tests mit einem Lambda empfangen, das an ein lokales `var got: Array = []` anhängt.
- `test_knoepfe`: `menu.box.get_child_count()` ist 6; `menu.herbivore_button.text` ist `"Neue Partie: Pflanzenfresser"`; `menu.quit_button.text` ist `"Beenden"`
- `test_neue_partie`: `menu.new_game.connect(func(d: String) -> void: got.append(d))`; `menu.carnivore_button.pressed.emit()` und danach `menu.herbivore_button.pressed.emit()` → `got.size()` ist 2, `got[0]` ist `Diet.FLEISCHFRESSER`, `got[1]` ist `Diet.PFLANZENFRESSER`
- `test_fortsetzen`: `menu.continue_button.disabled` wahr; `menu.set_can_continue(true)` → falsch; `menu.continue_game.connect(func() -> void: got.append(1))`, `menu.continue_button.pressed.emit()` → `got.size()` ist 1
- `test_beenden_und_einstellungen`: beide Signale verbinden (je ein anderer Wert anhängen), `quit_button.pressed.emit()` und `settings_button.pressed.emit()` → `got.size()` ist 2

Review (16.10.2026): gemergt.
