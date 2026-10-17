---
id: T-0199
title: Abnahmetest – Tempo und Wendigkeit in den Vorführszenen
project: zellenphase
priority: 3
---
## Ziel
Abnahmekriterium 6 verlangt messbare Unterschiede der Teile. Ein neuer Test belegt mit den Vorführszenen „tempo“ und „wendigkeit“ (`DemoScenes`, gestartet mit `main.start_scene(...)`), dass Geißeln schneller und Wimpern wendiger machen. Nur ein neuer Test, keine Änderungen an Skripten.

## Dateien
- `tests/test_abnahme_antrieb.gd`: neu

## Akzeptanzkriterien
- Nur `tests/test_abnahme_antrieb.gd` anlegen. Keine Datei unter `scripts/` ändern.
- Kopf: `extends "res://tests/base_test.gd"`, `const P := "user://test_abnahme_antrieb.json"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `main.save_path = P`, danach `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()` und die Datei `P` löschen, falls vorhanden (`DirAccess.remove_absolute(ProjectSettings.globalize_path(P))`). So wird nie der echte Spielstand überschrieben.

## Tests
- `test_tempo`: `main.start_scene("tempo")` → `main.player.motion.max_speed > CellStats.max_speed(CellBuild.starter(Diet.PFLANZENFRESSER), 1)` wahr; `main.player.build.count("geissel")` ist 2
- `test_tempo_gemessen`: `main.start_scene("tempo")`, dann 120-mal `main.player.drive(1.0 / 60.0, Vector2(1, 0))` → `var schnell: float = main.player.motion.position.x`; danach eine zweite Zelle zum Vergleich: `var p := PlayerCell.new()`, `p.set_stage(1)`, `p.set_build(CellBuild.starter(Diet.PFLANZENFRESSER))`, 120-mal `p.drive(1.0 / 60.0, Vector2(1, 0))` → `schnell > p.motion.position.x` wahr; am Ende `p.free()`
- `test_wendigkeit`: `main.start_scene("wendigkeit")` → `main.player.motion.turn_rate > CellStats.turn_rate(CellBuild.starter(Diet.PFLANZENFRESSER))` wahr; `main.player.build.count("wimpern")` ist 2
- `test_wendigkeit_gemessen`: `main.start_scene("wendigkeit")`, 10-mal `main.player.drive(1.0 / 60.0, Vector2(0, 1))` → `var w: float = absf(main.player.motion.heading)`; Vergleichszelle wie oben (`PlayerCell.new()`, `set_stage(1)`, Startaufbau), 10-mal `p.drive(1.0 / 60.0, Vector2(0, 1))` → `w > absf(p.motion.heading)` wahr; `p.free()`

Review (17.10.2026): gemergt.
