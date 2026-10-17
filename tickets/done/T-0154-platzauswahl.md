---
id: T-0154
title: Auswahlmenü für Spielstandplätze (SlotMenu)
project: zellenphase
priority: 3
after: T-0153
---
## Ziel
Ein Menü zeigt die drei Spielstandplätze mit Kurzbeschreibung. Bei „Fortsetzen“ sind nur belegte Plätze wählbar, bei „Neue Partie“ alle.

## Dateien
- `scripts/slot_menu.gd`: neu
- `tests/test_slot_menu.gd`: neu

## Akzeptanzkriterien
`scripts/slot_menu.gd` genau so:
```gdscript
class_name SlotMenu
extends CanvasLayer
## Auswahl eines der drei Spielstände. Meldet die Nummer (1 bis 3) oder Zurück.

signal slot_chosen(slot: int)
signal closed

var box: VBoxContainer
var title_label: Label
var slot_buttons: Array[Button] = []
var back_button: Button
var prefix := SaveSlots.PREFIX
## true: nur belegte Plätze wählbar (Fortsetzen); false: alle (neue Partie).
var only_used := false


func _init() -> void:
	layer = 11
	process_mode = Node.PROCESS_MODE_ALWAYS
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.04, 0.17, 0.24, 0.95)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	box = VBoxContainer.new()
	box.name = "Box"
	box.position = Vector2(700, 280)
	box.add_theme_constant_override("separation", 14)
	add_child(box)
	title_label = Label.new()
	title_label.name = "Title"
	title_label.add_theme_font_size_override("font_size", 40)
	box.add_child(title_label)
	for i in SaveSlots.COUNT:
		var b := Button.new()
		b.custom_minimum_size = Vector2(520, 56)
		b.pressed.connect(_choose.bind(i + 1))
		box.add_child(b)
		slot_buttons.append(b)
	back_button = Button.new()
	back_button.text = "Zurück"
	back_button.custom_minimum_size = Vector2(520, 56)
	back_button.pressed.connect(close)
	box.add_child(back_button)
	visible = false


## Öffnet die Auswahl mit Überschrift title und beschriftet die Plätze mit ihrer Kurzbeschreibung.
func open(title: String, p_only_used: bool) -> void:
	title_label.text = title
	only_used = p_only_used
	for i in SaveSlots.COUNT:
		var path := SaveSlots.path_for(i + 1, prefix)
		slot_buttons[i].text = "Platz %d: %s" % [i + 1, SaveSlots.summary(path)]
		slot_buttons[i].disabled = only_used and not FileAccess.file_exists(path)
	visible = true


func _choose(slot: int) -> void:
	visible = false
	slot_chosen.emit(slot)


func close() -> void:
	visible = false
	closed.emit()
```

## Tests
`tests/test_slot_menu.gd` mit `extends "res://tests/base_test.gd"`, `const P := "user://test_menue_platz_"`, `var menu: SlotMenu`; `setup()`: `menu = SlotMenu.new()`, `menu.prefix = P`; `teardown()`: `menu.free()` und für `slot` von 1 bis 3 die Datei `SaveSlots.path_for(slot, P)` löschen, falls vorhanden (`DirAccess.remove_absolute(ProjectSettings.globalize_path(path))`).
- `test_aufbau`: `menu.visible` falsch; `menu.slot_buttons.size()` ist 3; `menu.box.get_child_count()` ist 5
- `test_neue_partie`: `menu.open("Neue Partie", false)` → `menu.visible` wahr; `menu.title_label.text` ist `"Neue Partie"`; `menu.slot_buttons[0].text` ist `"Platz 1: Leer"`; `menu.slot_buttons[0].disabled` falsch
- `test_fortsetzen`: `SaveGame.write_file(SaveSlots.path_for(3, P), {"stage": 0, "dna": 5, "diet": Diet.FLEISCHFRESSER})`, `menu.open("Fortsetzen", true)` → `menu.slot_buttons[0].disabled` wahr; `menu.slot_buttons[2].disabled` falsch; `menu.slot_buttons[2].text` ist `"Platz 3: Größe 1 · 5 DNA · Fleischfresser"`
- `test_waehlen`: `var got: Array = []`, `menu.slot_chosen.connect(func(s: int) -> void: got.append(s))`, `menu.open("x", false)`, `menu.slot_buttons[1].pressed.emit()` → `got.size()` ist 1; `got[0]` ist 2; `menu.visible` falsch
- `test_zurueck`: `var got: Array = []`, `menu.closed.connect(func() -> void: got.append(1))`, `menu.open("x", false)`, `menu.back_button.pressed.emit()` → `got.size()` ist 1; `menu.visible` falsch

Review (16.10.2026): gemergt.
