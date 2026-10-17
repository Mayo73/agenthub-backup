---
id: T-0216
title: Abnahmetest – fünf Größenabschnitte im Spiel mit Kamera, Begegnungen und Gefahr, die zur Beute wird
project: zellenphase
priority: 3
---
## Ziel
Abnahmekriterium 4 im laufenden Spiel (`main.tscn`) statt nur in Einzelklassen: Fünf Größenabschnitte sind erreichbar, Zellgröße und Kamera ändern sich, die Begegnungen wechseln, und eine zuvor bedrohliche Art (Schnapper) wird später zur Beute. Nur ein neuer Test, keine Änderungen an Skripten.

## Dateien
- `tests/test_abnahme_groesse.gd`: neu

## Akzeptanzkriterien
- Nur `tests/test_abnahme_groesse.gd` anlegen. Keine Datei unter `scripts/` ändern.
- Kopf: `extends "res://tests/base_test.gd"`, `const P := "user://test_abnahme_groesse.json"`, `var main: Node2D`.
- `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `main.save_path = P`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`.
- `teardown()`: `main.free()`, dann `if FileAccess.file_exists(P): DirAccess.remove_absolute(ProjectSettings.globalize_path(P))`.
- Hilfsfunktionen (nicht `test_` benennen):
  - `func _eat_to_stage(kind: String, stage: int) -> void:` wiederholt höchstens 500-mal, solange `main.progress.stage < stage`: `main.food.items.clear()`, `main.food.add_item(kind, main.player.mouth_point())`, `main.feed_player()`.
  - `func _clear_ai() -> void:` ruft für jede Zelle in `main.ai_cells.duplicate()` `main.remove_ai(cell)` auf.
  - `func _species() -> Array[String]:` gibt die `species_id` aller Zellen in `main.ai_cells` zurück.

## Tests
- `test_fuenf_abschnitte`: `main.start_new(Diet.PFLANZENFRESSER)`; für `s` von 1 bis 4: `_eat_to_stage(Diet.PFLANZE, s)` → `main.progress.stage` ist `s`; `main.player.radius` ist `CellProgress.radius_for_stage(s)`; `main.player.radius > CellProgress.radius_for_stage(s - 1)` wahr
- `test_kamera_zoomt_heraus`: `main.start_new(Diet.PFLANZENFRESSER)`; `var last := 100.0`; für `s` von 0 bis 4: `_eat_to_stage(Diet.PFLANZE, s)`, dann dreimal `main._process(10.0)` → `absf(main.camera.zoom.x - CameraZoom.target_for_radius(main.player.radius)) < 0.01` wahr; `main.camera.zoom.x < last` wahr; danach `last = main.camera.zoom.x`
- `test_begegnungen_wechseln`: `main.start_new(Diet.PFLANZENFRESSER)`, `_clear_ai()`, `main.spawn_ai()` → `main.ai_cells.size()` ist `EcoSpawner.TARGET_COUNT`; jede ID aus `_species()` ist in `SpeciesCatalog.ids_near_stage(0)`. Dann `_clear_ai()`, `_eat_to_stage(Diet.PFLANZE, 4)`, `main.spawn_ai()` → jede ID aus `_species()` ist in `SpeciesCatalog.ids_near_stage(4)`; `SpeciesCatalog.ids_near_stage(0) != SpeciesCatalog.ids_near_stage(4)` wahr
- `test_gefahr_wird_beute`: `main.start_new(Diet.FLEISCHFRESSER)`; `var r := SpeciesCatalog.radius_of("schnapper")`, `var d: String = SpeciesCatalog.data("schnapper")["diet"]` → `AiBrain.is_threat(main.player.radius, r, d)` wahr. Dann `_eat_to_stage(Diet.FLEISCH, 3)` → `AiBrain.is_threat(main.player.radius, r, d)` falsch; `AiBrain.is_prey(main.player.radius, main.player.diet, r)` wahr. Dann `_clear_ai()`, `var cell := AiCell.new()`, `var pos: Vector2 = main.player.motion.position + Vector2.from_angle(main.player.motion.heading) * (main.player.radius + r * 0.5)`, `cell.setup("schnapper", pos)`, `main.world.add_child(cell)`, `main.ai_cells.append(cell)`, `cell.motion.position = pos`, `cell.position = pos`, `var vorher: float = cell.health.hp`, `main.resolve_combat()` → `cell.health.hp < vorher` wahr

Review (17.10.2026): gemergt.
