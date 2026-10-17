---
id: T-0049
title: Einstellungen speichern und anwenden (UserSettings)
project: drift
priority: 3
---
## Ziel
Lautstärke und Vollbild sollen einstellbar sein und einen Neustart überleben. Eine Klasse `UserSettings` hält die Werte, speichert sie als JSON im Benutzerordner und wendet sie an. (Die Tastenbelegung folgt später.)

## Dateien
- `scripts/user_settings.gd`: neu, beginnt mit `class_name UserSettings` und `extends RefCounted`
- `tests/test_user_settings.gd`: neu

## Akzeptanzkriterien
- `const DEFAULT_PATH := "user://einstellungen.json"`
- `var volume := 0.8` (0 bis 1) und `var fullscreen := false`
- `static func volume_db(v: float) -> float`: `-80.0`, wenn `v <= 0.001`, sonst `linear_to_db(v)`
- `func save(path: String = DEFAULT_PATH) -> bool`: wie bei einer JSON-Datei üblich: `FileAccess.open(path, FileAccess.WRITE)`, bei `null` `false`; sonst `store_string(JSON.stringify({"volume": volume, "fullscreen": fullscreen}))`, `close()`, `true`
- `static func load_from(path: String = DEFAULT_PATH) -> UserSettings`: neue Instanz; fehlt die Datei oder ist der Inhalt (`JSON.parse_string(FileAccess.get_file_as_string(path))`) kein `Dictionary`, die Standardwerte behalten; sonst `volume = clampf(float(d.get("volume", 0.8)), 0.0, 1.0)` und `fullscreen = bool(d.get("fullscreen", false))`
- `func apply() -> void`:
  ```gdscript
  	AudioServer.set_bus_volume_db(0, volume_db(volume))
  	if DisplayServer.get_name() != "headless":
  		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
  ```

## Tests
Neue Datei `tests/test_user_settings.gd` mit `extends "res://tests/base_test.gd"`, `const TEST_PATH := "user://test_einstellungen.json"`. In `teardown()` die Datei löschen, falls vorhanden (`DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))`) und `AudioServer.set_bus_volume_db(0, 0.0)`.
- `test_standardwerte`: `var s := UserSettings.new()` → `s.volume` ist 0.8, `s.fullscreen` ist falsch
- `test_lautstaerke_in_db`: `UserSettings.volume_db(1.0)` ist 0.0; `UserSettings.volume_db(0.0)` ist -80.0; `absf(UserSettings.volume_db(0.5) - linear_to_db(0.5)) < 0.001`
- `test_speichern_und_laden`: `var s := UserSettings.new()`, `s.volume = 0.25`, `s.fullscreen = true`, `check(s.save(TEST_PATH), …)`; `var l := UserSettings.load_from(TEST_PATH)` → `l.volume` ist 0.25, `l.fullscreen` ist wahr
- `test_fehlende_datei`: `UserSettings.load_from("user://gibt_es_nicht.json").volume` ist 0.8
- `test_anwenden`: `var s := UserSettings.new()`, `s.volume = 0.5`, `s.apply()` → `absf(AudioServer.get_bus_volume_db(0) - linear_to_db(0.5)) < 0.01`

Review (16.10.2026): gemergt, nachgebessert: load_from fängt Dateien ohne Dictionary sicher ab.
