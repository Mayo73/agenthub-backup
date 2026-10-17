---
id: T-0018
title: Hauptmenü-Szene
project: drift
priority: 3
---
## Ziel
Ein Hauptmenü mit Titel und drei Knöpfen: „Rennen starten“ wechselt zur Rennszene, „Einstellungen“ ist vorerst ausgegraut, „Beenden“ schließt das Spiel. Das Menü wird noch nicht als Startszene eingetragen (eigenes Ticket).

## Dateien
- `scenes/main_menu.tscn`: neu, Inhalt genau wie unten
- `scripts/main_menu.gd`: neu
- `tests/test_main_menu.gd`: neu

## Akzeptanzkriterien
- `scenes/main_menu.tscn` mit genau diesem Inhalt:
  ```
  [gd_scene format=3]

  [ext_resource type="Script" path="res://scripts/main_menu.gd" id="1_menu"]

  [node name="MainMenu" type="Control"]
  layout_mode = 3
  anchors_preset = 15
  anchor_right = 1.0
  anchor_bottom = 1.0
  grow_horizontal = 2
  grow_vertical = 2
  script = ExtResource("1_menu")

  [node name="Background" type="ColorRect" parent="."]
  layout_mode = 1
  anchors_preset = 15
  anchor_right = 1.0
  anchor_bottom = 1.0
  grow_horizontal = 2
  grow_vertical = 2
  color = Color(0.1, 0.11, 0.13, 1)

  [node name="Buttons" type="VBoxContainer" parent="."]
  layout_mode = 1
  anchors_preset = 8
  anchor_left = 0.5
  anchor_top = 0.5
  anchor_right = 0.5
  anchor_bottom = 0.5
  offset_left = -160.0
  offset_top = -140.0
  offset_right = 160.0
  offset_bottom = 140.0
  theme_override_constants/separation = 16

  [node name="Title" type="Label" parent="Buttons"]
  layout_mode = 2
  theme_override_font_sizes/font_size = 64
  text = "DRIFT"
  horizontal_alignment = 1

  [node name="Start" type="Button" parent="Buttons"]
  layout_mode = 2
  theme_override_font_sizes/font_size = 28
  text = "Rennen starten"

  [node name="Settings" type="Button" parent="Buttons"]
  layout_mode = 2
  theme_override_font_sizes/font_size = 28
  disabled = true
  text = "Einstellungen"

  [node name="Quit" type="Button" parent="Buttons"]
  layout_mode = 2
  theme_override_font_sizes/font_size = 28
  text = "Beenden"
  ```
- `scripts/main_menu.gd`:
  - `extends Control`
  - `const GAME_SCENE := "res://scenes/main.tscn"`
  - `@onready var start_button: Button = $Buttons/Start`, `@onready var settings_button: Button = $Buttons/Settings`, `@onready var quit_button: Button = $Buttons/Quit`
  - `func _ready() -> void:` verbindet `start_button.pressed` mit `start_game` und `quit_button.pressed` mit `quit_game`, dann `start_button.grab_focus()`
  - `func start_game() -> void:` `get_tree().change_scene_to_file(GAME_SCENE)`
  - `func quit_game() -> void:` `get_tree().quit()`

## Tests
Neue Datei `tests/test_main_menu.gd` mit `extends "res://tests/base_test.gd"`:

```gdscript
var menu: Control

func setup() -> void:
	menu = load("res://scenes/main_menu.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(menu)

func teardown() -> void:
	menu.free()
	menu = null
```

- `test_knoepfe`: `menu.start_button.text` ist `"Rennen starten"`, `menu.settings_button.text` ist `"Einstellungen"`, `menu.settings_button.disabled` ist wahr, `menu.quit_button.text` ist `"Beenden"`
- `test_knoepfe_verbunden`: `menu.start_button.pressed.is_connected(menu.start_game)` und `menu.quit_button.pressed.is_connected(menu.quit_game)` sind wahr
- `test_rennszene_existiert`: `ResourceLoader.exists(menu.GAME_SCENE)` ist wahr

`start_game()` und `quit_game()` im Test **nicht** aufrufen (das würde den Testlauf beenden).

Review (16.10.2026): gemergt.
