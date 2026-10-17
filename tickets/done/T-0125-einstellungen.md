---
id: T-0125
title: Einstellungen dauerhaft speichern (UserSettings)
project: zellenphase
priority: 3
---
## Ziel
Lautstärke für Musik und Effekte, Vollbild und Auflösung werden dauerhaft gespeichert (Lastenheft „Audio und Einstellungen“, Abnahmekriterium 10). Diese Klasse hält die Werte, begrenzt sie und speichert sie als ConfigFile.

## Dateien
- `scripts/user_settings.gd`: neu
- `tests/test_user_settings.gd`: neu

## Akzeptanzkriterien
`scripts/user_settings.gd` genau so:
```gdscript
class_name UserSettings
extends RefCounted
## Einstellungen, die dauerhaft gespeichert werden: Lautstärken, Vollbild, Auflösung.

const DEFAULT_PATH := "user://einstellungen.cfg"
const RESOLUTIONS := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440)]

var music_volume := 0.8
var sfx_volume := 0.8
var fullscreen := false
var resolution_index := 2


func set_music_volume(v: float) -> void:
	music_volume = clampf(v, 0.0, 1.0)


func set_sfx_volume(v: float) -> void:
	sfx_volume = clampf(v, 0.0, 1.0)


func set_resolution_index(i: int) -> void:
	resolution_index = clampi(i, 0, RESOLUTIONS.size() - 1)


func resolution() -> Vector2i:
	return RESOLUTIONS[resolution_index]


## Lautstärke 0 bis 1 in Dezibel für einen Audiobus; 0 ergibt -80 dB (stumm).
static func to_db(v: float) -> float:
	if v <= 0.0:
		return -80.0
	return linear_to_db(v)


func save(path: String = DEFAULT_PATH) -> bool:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("display", "fullscreen", fullscreen)
	cfg.set_value("display", "resolution", resolution_index)
	return cfg.save(path) == OK


## Lädt gespeicherte Werte; fehlt die Datei, bleiben die Standardwerte. Ungültige Werte werden begrenzt.
func load_from(path: String = DEFAULT_PATH) -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return false
	set_music_volume(float(cfg.get_value("audio", "music", music_volume)))
	set_sfx_volume(float(cfg.get_value("audio", "sfx", sfx_volume)))
	fullscreen = bool(cfg.get_value("display", "fullscreen", fullscreen))
	set_resolution_index(int(cfg.get_value("display", "resolution", resolution_index)))
	return true
```

## Tests
`tests/test_user_settings.gd` mit `extends "res://tests/base_test.gd"`, `const PATH := "user://test_einstellungen.cfg"`, `var s: UserSettings`; `setup()`: `s = UserSettings.new()`; `teardown()`: `if FileAccess.file_exists(PATH): DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))`.
- `test_standard`: `s.music_volume` ist 0.8; `s.fullscreen` falsch; `s.resolution() == Vector2i(1920, 1080)` wahr
- `test_grenzen`: `s.set_music_volume(1.5)` → 1.0; `s.set_sfx_volume(-1.0)` → 0.0; `s.set_resolution_index(9)` → `s.resolution_index` ist 3
- `test_dezibel`: `UserSettings.to_db(0.0)` ist -80.0; `UserSettings.to_db(1.0)` ist 0.0
- `test_speichern_laden`: `s.set_music_volume(0.3)`, `s.fullscreen = true`, `s.set_resolution_index(0)`; `s.save(PATH)` wahr; `var t := UserSettings.new()`; `t.load_from(PATH)` wahr → `t.music_volume` ist 0.3, `t.sfx_volume` ist 0.8, `t.fullscreen` wahr, `t.resolution_index` ist 0
- `test_fehlende_datei`: `s.load_from("user://gibtsnicht.cfg")` falsch; `s.music_volume` ist 0.8

Review (16.10.2026): gemergt.
