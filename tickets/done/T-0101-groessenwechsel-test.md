---
id: T-0101
title: Test – aus Gefahr wird Beute
project: zellenphase
priority: 5
after: T-0083, T-0085, T-0092, T-0093
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Ein Test hält das Abnahmekriterium 4 fest: Fünf Größenabschnitte sind erreichbar, die Kamera zoomt mit jedem heraus, jeder Abschnitt hat Begegnungen, und eine anfangs bedrohliche Zellart wird später zur Beute. Nur ein neuer Test, keine Änderungen an Skripten.

## Dateien
- `tests/test_size_progression.gd`: neu

## Akzeptanzkriterien
- Nur `tests/test_size_progression.gd` anlegen, mit `extends "res://tests/base_test.gd"`. Keine Datei unter `scripts/` ändern.

## Tests
- `test_fuenf_abschnitte`: `var p := CellProgress.new()`; 200-mal `p.eat(1)` und dabei jede neue `p.stage` in ein `Array[int]` aufnehmen (mit 0 beginnen) → das Array ist `[0, 1, 2, 3, 4]` (typisiertes Array zum Vergleich)
- `test_radius_waechst`: für `s` von 1 bis 4 ist `CellProgress.radius_for_stage(s) > CellProgress.radius_for_stage(s - 1)`
- `test_zoom_sinkt`: für `s` von 1 bis 4 ist `CameraZoom.target_for_radius(CellProgress.radius_for_stage(s)) < CameraZoom.target_for_radius(CellProgress.radius_for_stage(s - 1))`
- `test_begegnungen_je_abschnitt`: für jede Stufe 0 bis 4 hat `SpeciesCatalog.ids_near_stage(s).size()` mindestens 2
- `test_aus_gefahr_wird_beute`: mit `var schnapper := SpeciesCatalog.radius_of("schnapper")` und `var diet: String = SpeciesCatalog.data("schnapper")["diet"]`:
  - `AiBrain.is_threat(CellProgress.radius_for_stage(0), schnapper, diet)` ist wahr
  - `AiBrain.is_threat(CellProgress.radius_for_stage(3), schnapper, diet)` ist falsch
  - `AiBrain.is_prey(CellProgress.radius_for_stage(3), Diet.FLEISCHFRESSER, schnapper)` ist wahr

Review (16.10.2026): gemergt.
