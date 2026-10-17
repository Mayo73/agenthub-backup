---
id: T-0139
title: Einstellungen aus Haupt- und Pausemenü öffnen und anwenden
project: zellenphase
priority: 5
after: T-0138, T-0129
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Die Knöpfe „Einstellungen“ im Haupt- und im Pausemenü öffnen das Einstellungsmenü. Beim Schließen werden die Einstellungen gespeichert und angewendet (Lautstärke der Audiobusse, Vollbild, Auflösung). Beim Start werden gespeicherte Einstellungen geladen (Abnahmekriterium 10).

## Dateien
- `scripts/main.gd`
- `tests/test_main_settings.gd`: neu

## Akzeptanzkriterien
- Neue Variablen direkt unter `var paused := false`:
```gdscript
var settings := UserSettings.new()
var settings_path := UserSettings.DEFAULT_PATH
var settings_menu: SettingsMenu
```
- Am Ende von `_ready()`:
```gdscript
	settings.load_from(settings_path)
	settings_menu = SettingsMenu.new()
	settings_menu.name = "SettingsMenu"
	add_child(settings_menu)
	main_menu.open_settings.connect(open_settings)
	pause_menu.open_settings.connect(open_settings)
	settings_menu.closed.connect(close_settings)
	apply_settings()
```
- Neue Funktionen am Ende:
```gdscript
func open_settings() -> void:
	settings_menu.show_settings(settings)


func close_settings() -> void:
	settings.save(settings_path)
	apply_settings()


## Wendet Lautstärken (Audiobusse "Musik" und "Effekte", falls vorhanden), Vollbild und Auflösung an.
func apply_settings() -> void:
	var music := AudioServer.get_bus_index("Musik")
	if music >= 0:
		AudioServer.set_bus_volume_db(music, UserSettings.to_db(settings.music_volume))
	var sfx := AudioServer.get_bus_index("Effekte")
	if sfx >= 0:
		AudioServer.set_bus_volume_db(sfx, UserSettings.to_db(settings.sfx_volume))
	if DisplayServer.get_name() == "headless":
		return
	if settings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(settings.resolution())
```
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_settings.gd` mit `extends "res://tests/base_test.gd"`, `const PATH := "user://test_main_einstellungen.cfg"`, `var main: Node2D`;
`setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`, `main.settings_path = PATH`;
`teardown()`: `main.free()` und `if FileAccess.file_exists(PATH): DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))`.
- `test_aus_hauptmenue`: `main.main_menu.settings_button.pressed.emit()` → `main.settings_menu.visible` wahr; `main.settings_menu.settings == main.settings` wahr
- `test_aus_pause`: `main.main_menu.herbivore_button.pressed.emit()`, `main.toggle_pause()`, `main.pause_menu.settings_button.pressed.emit()` → `main.settings_menu.visible` wahr
- `test_speichern_beim_schliessen`: `main.open_settings()`, `main.settings_menu.music_slider.value = 0.4`, `main.settings_menu.back_button.pressed.emit()` → `FileAccess.file_exists(PATH)` wahr; `var s := UserSettings.new()`, `s.load_from(PATH)` → `s.music_volume` ist 0.4; `main.settings_menu.visible` falsch

Review (16.10.2026): gemergt.
