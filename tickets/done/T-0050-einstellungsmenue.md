---
id: T-0050
title: Einstellungsmenü-Szene
project: drift
priority: 3
after: T-0049
---
## Ziel
Ein Einstellungsmenü mit Lautstärke-Regler, Vollbild-Schalter und „Zurück“. Änderungen wirken sofort; „Zurück“ speichert und kehrt ins Hauptmenü zurück. Eingebaut ins Hauptmenü wird es im nächsten Ticket.

## Dateien
- `scenes/settings_menu.tscn`: neu, Inhalt genau wie unten
- `scripts/settings_menu.gd`: neu
- `tests/test_settings_menu.gd`: neu

## Akzeptanzkriterien
- `scenes/settings_menu.tscn` mit genau diesem Inhalt:
  ```
  [gd_scene format=3]

  [ext_resource type="Script" path="res://scripts/settings_menu.gd" id="1_settings"]

  [node name="SettingsMenu" type="Control"]
  layout_mode = 3
  anchors_preset = 15
  anchor_right = 1.0
  anchor_bottom = 1.0
  grow_horizontal = 2
  grow_vertical = 2
  script = ExtResource("1_settings")

  [node name="Background" type="ColorRect" parent="."]
  layout_mode = 1
  anchors_preset = 15
  anchor_right = 1.0
  anchor_bottom = 1.0
  grow_horizontal = 2
  grow_vertical = 2
  color = Color(0.1, 0.11, 0.13, 1)

  [node name="Items" type="VBoxContainer" parent="."]
  layout_mode = 1
  anchors_preset = 8
  anchor_left = 0.5
  anchor_top = 0.5
  anchor_right = 0.5
  anchor_bottom = 0.5
  offset_left = -200.0
  offset_top = -150.0
  offset_right = 200.0
  offset_bottom = 150.0
  theme_override_constants/separation = 18

  [node name="Title" type="Label" parent="Items"]
  layout_mode = 2
  theme_override_font_sizes/font_size = 48
  text = "Einstellungen"
  horizontal_alignment = 1

  [node name="VolumeRow" type="HBoxContainer" parent="Items"]
  layout_mode = 2
  theme_override_constants/separation = 16

  [node name="VolumeLabel" type="Label" parent="Items/VolumeRow"]
  layout_mode = 2
  theme_override_font_sizes/font_size = 24
  text = "Lautstärke"

  [node name="Volume" type="HSlider" parent="Items/VolumeRow"]
  custom_minimum_size = Vector2(220, 0)
  layout_mode = 2
  size_flags_vertical = 4
  max_value = 1.0
  step = 0.05

  [node name="Fullscreen" type="CheckBox" parent="Items"]
  layout_mode = 2
  theme_override_font_sizes/font_size = 24
  text = "Vollbild"

  [node name="Back" type="Button" parent="Items"]
  layout_mode = 2
  theme_override_font_sizes/font_size = 28
  text = "Zurück"
  ```
- `scripts/settings_menu.gd`:
  - `extends Control`
  - `const MENU_SCENE := "res://scenes/main_menu.tscn"`
  - `var settings_path := UserSettings.DEFAULT_PATH` und `var settings: UserSettings`
  - `@onready var volume_slider: HSlider = $Items/VolumeRow/Volume`, `@onready var fullscreen_box: CheckBox = $Items/Fullscreen`, `@onready var back_button: Button = $Items/Back`
  - `func _ready() -> void:` `settings = UserSettings.load_from(settings_path)`; `volume_slider.value = settings.volume`; `fullscreen_box.button_pressed = settings.fullscreen`; **danach** verbinden: `volume_slider.value_changed` → `_on_volume_changed`, `fullscreen_box.toggled` → `_on_fullscreen_toggled`, `back_button.pressed` → `go_back`; dann `back_button.grab_focus()`
  - `func _on_volume_changed(value: float) -> void:` `settings.volume = value`, `settings.apply()`
  - `func _on_fullscreen_toggled(on: bool) -> void:` `settings.fullscreen = on`, `settings.apply()`
  - `func save_settings() -> void:` `settings.save(settings_path)`
  - `func go_back() -> void:` `save_settings()`, dann `get_tree().change_scene_to_file(MENU_SCENE)`

## Tests
Neue Datei `tests/test_settings_menu.gd` mit `extends "res://tests/base_test.gd"`:
```gdscript
const TEST_PATH := "user://test_menu_einstellungen.json"
var menu: Control

func setup() -> void:
	menu = load("res://scenes/settings_menu.tscn").instantiate()
	menu.settings_path = TEST_PATH
	(Engine.get_main_loop() as SceneTree).root.add_child(menu)

func teardown() -> void:
	menu.free()
	menu = null
	AudioServer.set_bus_volume_db(0, 0.0)
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
```
- `test_startwerte`: `menu.volume_slider.value` ist 0.8 (mit `absf(… - 0.8) < 0.001`), `menu.fullscreen_box.button_pressed` ist falsch
- `test_lautstaerke_aendern`: `menu.volume_slider.value = 0.5` → `menu.settings.volume` ist 0.5 und `absf(AudioServer.get_bus_volume_db(0) - linear_to_db(0.5)) < 0.01`
- `test_speichern`: `menu.volume_slider.value = 0.3`, `menu.save_settings()` → `absf(UserSettings.load_from(TEST_PATH).volume - 0.3) < 0.001`
- `test_knoepfe_verbunden`: `menu.back_button.pressed.is_connected(menu.go_back)` ist wahr; `ResourceLoader.exists(menu.MENU_SCENE)` ist wahr

`go_back()` im Test **nicht** aufrufen.

Review (16.10.2026): gemergt.
