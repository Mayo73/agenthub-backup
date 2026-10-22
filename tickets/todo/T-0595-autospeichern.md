---
id: T-0595
title: AutosaveTimer – automatisch speichern, wenn sich etwas geändert hat
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“ (Editor): Entscheiden, wann der Editor automatisch speichert: nur bei ungespeicherten Änderungen und erst nach einer festen Zeit.

## Dateien
- `core/autosave_timer.gd` – neu, Klasse `AutosaveTimer`
- `tests/test_autosave_timer.gd` – neu

## Akzeptanzkriterien
`class_name AutosaveTimer`, `extends RefCounted`.
- `var interval := 60.0`, `var elapsed := 0.0`, `var dirty := false`
- `func _init(seconds: float = 60.0) -> void`: `interval = seconds`
- `func mark_dirty() -> void`: `dirty = true`
- `func tick(dt: float) -> bool`: ohne `dirty` → `false`, `elapsed` bleibt 0.0. Mit `dirty`: `elapsed += dt`; ist `elapsed >= interval`, dann `elapsed = 0.0`, `dirty = false` und `true`; sonst `false`
- `func saved() -> void`: `dirty = false`, `elapsed = 0.0` (von Hand gespeichert)

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs.

## Tests
`tests/test_autosave_timer.gd`, jeweils `AutosaveTimer.new(10.0)`:
- `test_ohne_aenderung`: `tick(30.0)` falsch, `elapsed` 0.0
- `test_speichern`: `mark_dirty()`, `tick(6.0)` falsch, `tick(5.0)` wahr; danach `dirty` falsch und `elapsed` 0.0; `tick(20.0)` falsch
- `test_von_hand`: `mark_dirty()`, `tick(8.0)`, `saved()` → `dirty` falsch, `elapsed` 0.0, `tick(20.0)` falsch
