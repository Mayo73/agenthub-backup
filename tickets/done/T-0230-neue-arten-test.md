---
id: T-0230
title: Test für die drei neuen Zellarten im Ökosystem
project: zellenphase
priority: 2
after: T-0229, T-0222
---
## Ziel
Belegen, dass die neuen Arten aus T-0229 im Spiel funktionieren: Sie erscheinen in den richtigen Größenabschnitten, die KI-Zelle übernimmt ihre Werte, der Flimmerling flieht vor der wachsenden Spielerzelle und die Stacheln des Panzerlings zeigen nach hinten.

## Dateien
- `tests/test_neue_arten.gd` – neu

## Akzeptanzkriterien
- Nur die neue Testdatei anlegen, keine andere Datei ändern.
- Alle Tests bestehen mit dem vorhandenen Code (`SpeciesCatalog`, `AiBrain`, `AiCell`, `EcoSpawner`, `SpeciesWeapons`, `CellProgress`, `Diet`).

## Tests
`tests/test_neue_arten.gd` mit `extends "res://tests/base_test.gd"`:
- `test_abschnitte`: `SpeciesCatalog.ids_near_stage(0).has("flimmerling")` wahr; `SpeciesCatalog.ids_near_stage(3).has("panzerling")` wahr; `SpeciesCatalog.ids_near_stage(4).has("schwebqualle")` wahr; `SpeciesCatalog.ids_near_stage(2).has("schwebqualle")` falsch
- `test_flimmerling_flieht`: `AiBrain.is_threat(SpeciesCatalog.radius_of("flimmerling"), CellProgress.radius_for_stage(1), Diet.FLEISCHFRESSER)` wahr; `AiBrain.is_threat(SpeciesCatalog.radius_of("flimmerling"), CellProgress.radius_for_stage(0), Diet.FLEISCHFRESSER)` falsch
- `test_ki_zelle`: `var c := AiCell.new()`, `c.setup("panzerling", Vector2(5, 5))` → `c.radius` ist 27.0; `c.damage` ist 0.0; `c.diet` ist `Diet.PFLANZENFRESSER`; `c.motion.max_speed` ist 70.0; `c.behavior` ist `"scheu"`; am Ende `c.free()`
- `test_panzerling_stacheln`: `var t := SpeciesWeapons.spike_tips("panzerling", Vector2.ZERO, 0.0, 27.0)` → `t.size()` ist 2; `t[0].x < 0.0` wahr; `t[1].x < 0.0` wahr
- `test_spawner`: `var s := EcoSpawner.new(3)`; 300-mal `s.pick_species(0)` aufrufen → `"flimmerling"` kommt mindestens einmal vor; 300-mal `s.pick_species(4)` → `"schwebqualle"` kommt mindestens einmal vor, `"flimmerling"` nie

Review (17.10.2026): gemergt.
