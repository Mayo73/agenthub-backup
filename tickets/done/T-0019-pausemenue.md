---
id: T-0019
title: Pausemenü-Szene
project: drift
priority: 3
after: T-0017, T-0018
---
## Ziel
Ein Pausemenü, das sich mit Esc (Aktion `pause` aus T-0017) öffnet und schließt und dabei das Spiel anhält. Knöpfe: „Weiter“, „Neustart“, „Zum Menü“. Noch nicht in die Rennszene einbauen.

## Dateien
- `scenes/pause_menu.tscn`: neu, Inhalt genau wie unten
- `scripts/pause_menu.gd`: neu
- `tests/test_pause_menu.gd`: neu

## Akzeptanzkriterien
- `scenes/pause_menu.tscn` mit genau diesem Inhalt (`process_mode = 3` heißt: läuft auch, wenn das Spiel pausiert ist):
  ```
  [gd_scene format=3]

  [ext_resource type="Script" path="res://scripts/pause_menu.gd" id="1_pause"]

  [node name="PauseMenu" type="CanvasLayer"]
  process_mode = 3
  layer = 10
  visible = false
  script = ExtResource("1_pause")

  [node name="Dim" type="ColorRect" parent="."]
  anchors_preset = 15
  anchor_right = 1.0
  anchor_bottom = 1.0
  color = Color(0, 0, 0, 0.55)

  [node name="Buttons" type="VBoxContainer" parent="."]
  anchors_preset = 8
  anchor_left = 0.5
  anchor_top = 0.5
  anchor_right = 0.5
  anchor_bottom = 0.5
  offset_left = -150.0
  offset_top = -130.0
  offset_right = 150.0
  offset_bottom = 130.0
  theme_override_constants/separation = 14

  [node name="Title" type="Label" parent="Buttons"]
  layout_mode = 2
  theme_override_font_sizes/font_size = 48
  text = "Pause"
  horizontal_alignment = 1

  [node name="Resume" type="Button" parent="Buttons"]
  layout_mode = 2
  theme_override_font_sizes/font_size = 26
  text = "Weiter"

  [node name="Restart" type="Button" parent="Buttons"]
  layout_mode = 2
  theme_override_font_sizes/font_size = 26
  text = "Neustart"

  [node name="Menu" type="Button" parent="Buttons"]
  layout_mode = 2
  theme_override_font_sizes/font_size = 26
  text = "Zum Menü"
  ```
- `scripts/pause_menu.gd`:
  - `extends CanvasLayer`
  - `signal restart_requested`
  - `const MENU_SCENE := "res://scenes/main_menu.tscn"`
  - `@onready var resume_button: Button = $Buttons/Resume`, `@onready var restart_button: Button = $Buttons/Restart`, `@onready var menu_button: Button = $Buttons/Menu`
  - `func _ready() -> void:` `visible = false`; verbindet `resume_button.pressed` → `close`, `restart_button.pressed` → `_on_restart`, `menu_button.pressed` → `_on_menu`
  - `func open() -> void:` `visible = true`, `get_tree().paused = true`, `resume_button.grab_focus()`
  - `func close() -> void:` `visible = false`, `get_tree().paused = false`
  - `func toggle() -> void:` ruft `close()`, wenn `visible`, sonst `open()`
  - `func _unhandled_input(event: InputEvent) -> void:` wenn `event.is_action_pressed("pause")`: `toggle()` und `get_viewport().set_input_as_handled()`
  - `func _on_restart() -> void:` `close()`, dann `restart_requested.emit()`
  - `func _on_menu() -> void:` `close()`, dann `get_tree().change_scene_to_file(MENU_SCENE)`

## Tests
Neue Datei `tests/test_pause_menu.gd` mit `extends "res://tests/base_test.gd"`:

```gdscript
var pause: CanvasLayer

func setup() -> void:
	Controls.setup()
	pause = load("res://scenes/pause_menu.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(pause)

func teardown() -> void:
	(Engine.get_main_loop() as SceneTree).paused = false
	pause.free()
	pause = null
```

- `test_start_geschlossen`: `pause.visible` ist falsch
- `test_oeffnen_und_schliessen`: `pause.open()` → `pause.visible` wahr und `pause.get_tree().paused` wahr; `pause.close()` → beide falsch
- `test_umschalten`: `pause.toggle()` → `pause.visible` wahr; `pause.toggle()` → `pause.visible` falsch
- `test_neustart_signal`: `var count := [0]`, `pause.restart_requested.connect(func() -> void: count[0] += 1)`, `pause.open()`, `pause._on_restart()` → `count[0]` ist 1, `pause.get_tree().paused` falsch
- `test_menueszene_existiert`: `ResourceLoader.exists(pause.MENU_SCENE)` ist wahr

`_on_menu()` im Test **nicht** aufrufen.

Review (16.10.2026): gemergt.
