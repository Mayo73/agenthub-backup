---
id: T-0212
title: Schwierigkeitsgrad in den Einstellungen speichern
project: zellenphase
priority: 3
after: T-0211
---
## Ziel
Der gewählte Schwierigkeitsgrad wird wie Lautstärke und Auflösung in `UserSettings` dauerhaft gespeichert.

## Dateien
- `scripts/user_settings.gd`
- `tests/test_user_settings.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
In `scripts/user_settings.gd`:
- Neue Variable direkt unter `var resolution_index := 2`: `var difficulty := Difficulty.NORMAL`
- Neue Funktion direkt unter `func set_resolution_index(...)` (nach deren Rumpf, mit zwei Leerzeilen Abstand):
```gdscript
func set_difficulty(i: int) -> void:
	difficulty = Difficulty.clamp_index(i)
```
- In `save(...)` direkt vor der Zeile `return cfg.save(path) == OK`: `cfg.set_value("game", "difficulty", difficulty)`
- In `load_from(...)` direkt vor der letzten Zeile `return true`: `set_difficulty(int(cfg.get_value("game", "difficulty", difficulty)))`
- Sonst nichts ändern.

## Tests
In `tests/test_user_settings.gd` anhängen (dort gibt es schon `PATH` und `s`):
- `test_schwierigkeit_standard`: `s.difficulty` ist `Difficulty.NORMAL`
- `test_schwierigkeit_grenzen`: `s.set_difficulty(5)` → `s.difficulty` ist 2; `s.set_difficulty(-1)` → `s.difficulty` ist 0
- `test_schwierigkeit_gespeichert`: `s.set_difficulty(2)`, `s.save(PATH)`; `var t := UserSettings.new()`, `t.load_from(PATH)` → `t.difficulty` ist 2

Review (17.10.2026): gemergt.
