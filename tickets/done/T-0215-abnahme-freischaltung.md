---
id: T-0215
title: Abnahmetest – Teile freischalten, gesperrte und zu teure Teile, DNA nie negativ
project: zellenphase
priority: 3
---
## Ziel
Abnahmekriterium 7: Teile lassen sich über Funde und besiegte Zellen freischalten und dann im Editor verwenden. Nicht freigeschaltete oder unbezahlbare Teile können nicht verbindlich eingebaut werden; DNA wird nie negativ. Nur ein neuer Test, keine Änderungen an Skripten.

## Dateien
- `tests/test_abnahme_freischaltung.gd`: neu

## Akzeptanzkriterien
- Nur `tests/test_abnahme_freischaltung.gd` anlegen. Keine Datei unter `scripts/` ändern.
- Kopf: `extends "res://tests/base_test.gd"`, `const P := "user://test_abnahme_freischaltung.json"`, `var main: Node2D`.
- `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `main.save_path = P`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`, `main.start_new(Diet.FLEISCHFRESSER)`.
- `teardown()`: `main.free()`, dann `if FileAccess.file_exists(P): DirAccess.remove_absolute(ProjectSettings.globalize_path(P))`.
- Hilfsfunktion (nicht `test_` benennen) `func _place(id: String, screen: Vector2) -> void:` ruft `main.editor.canvas.symmetry = false`, `main.editor.panel.select(id)` und `main.editor.canvas.click(screen)` auf. Bildschirmpunkte: (752, 696) und (752, 384) liegen auf der Zelle.

## Tests
- `test_gesperrt_nicht_einbaubar`: `main.progress.dna = 100`; `main.unlocks.is_unlocked("geissel")` ist falsch; `main.open_editor()`, `_place("geissel", Vector2(752, 696))` → `main.editor.session.working.parts.size()` ist 2; `main.editor.confirm()` → `main.progress.dna` ist 100; `main.player.build.count("geissel")` ist 0
- `test_fund_schaltet_frei`: `main.pickups.positions.clear()`, `main.pickups.positions.append(main.player.position)`, `main.collect_pickups()` → `main.unlocks.is_unlocked("geissel")` wahr; `main.pickups.positions.size()` ist 0. Dann `main.progress.dna = 15`, `main.open_editor()`, `_place("geissel", Vector2(752, 696))`, `main.editor.confirm()` → `main.editor_open` falsch; `main.progress.dna` ist 0; `main.player.build.count("geissel")` ist 1
- `test_beute_schaltet_frei`: `var cell := AiCell.new()`, `cell.setup("stachelkugel", Vector2(5000, 0))`, `main.world.add_child(cell)`, `main.ai_cells.append(cell)`, `cell.health.damage(1000.0)`, `main.resolve_combat()` → `main.unlocks.is_unlocked("stachel")` wahr; `main.ai_cells.has(cell)` falsch. Dann `main.progress.dna = 15`, `main.open_editor()`, `_place("stachel", Vector2(752, 696))`, `main.editor.confirm()` → `main.player.build.count("stachel")` ist 1; `main.progress.dna` ist 0
- `test_zu_teuer`: `main.unlocks.unlock("elektro")`, `main.progress.dna = 24`, `main.open_editor()`, `_place("elektro", Vector2(752, 696))` → `main.editor.session.cost()` ist 25; `main.editor.panel.confirm_button.disabled` wahr; `main.editor.confirm()` → `main.editor_open` wahr; `main.progress.dna` ist 24. Dann `main.editor.cancel()` → `main.editor_open` falsch; `main.progress.dna` ist 24; `main.player.build.count("elektro")` ist 0
- `test_dna_nie_negativ`: `main.unlocks.unlock("elektro")`, `main.unlocks.unlock("stachel")`, `main.progress.dna = 25`; `main.open_editor()`, `_place("elektro", Vector2(752, 696))`, `main.editor.confirm()` → `main.progress.dna` ist 0. Dann `main.open_editor()`, `_place("stachel", Vector2(752, 384))`, `main.editor.confirm()` → `main.editor_open` wahr; `main.progress.dna` ist 0; `main.editor.cancel()`. Zum Schluss `main.progress.spend(10)` ist falsch und `main.progress.dna` ist 0

Review (17.10.2026): gemergt.
