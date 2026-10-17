---
id: T-0202
title: Abnahmetest – dreimal Ruf, Partner, Editor und zurück ins Spiel
project: zellenphase
priority: 3
---
## Ziel
Abnahmekriterium 8: Ruf, Partnersuche, Editor und Rückkehr ins Spiel funktionieren mindestens dreimal in einer Partie; die Umbauten bleiben erhalten. Nur ein neuer Test, keine Änderungen an Skripten.

## Dateien
- `tests/test_abnahme_editor_dreimal.gd`: neu

## Akzeptanzkriterien
- Nur `tests/test_abnahme_editor_dreimal.gd` anlegen. Keine Datei unter `scripts/` ändern.
- Kopf: `extends "res://tests/base_test.gd"`, `const P := "user://test_abnahme_editor.json"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `main.save_path = P`, danach `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()` und die Datei `P` löschen, falls vorhanden (`DirAccess.remove_absolute(ProjectSettings.globalize_path(P))`). So wird nie der echte Spielstand überschrieben.
- Hilfsfunktion (nicht `test_` benennen) für einen Partnerbesuch:
```gdscript
func _visit() -> void:
	main.mate.add_charge()
	main.call_mate()
	main.player.position = main.mate.partner_pos
	main.update_mate()
```
- Hilfsfunktion `func _play_a_bit() -> void:` ruft 30-mal `main._physics_process(1.0 / 60.0)` auf.

## Tests
- `test_dreimal`, alles in einem Test der Reihe nach:
  1. `main.start_new(Diet.PFLANZENFRESSER)`, `main.progress.dna = 30`, `main.unlocks.unlock("geissel")`
  2. Besuch 1: `_visit()` → `main.editor_open` wahr; `main.editor.panel.select("geissel")`, `main.editor.canvas.click(Vector2(752, 696))`, `main.editor.confirm()` → `main.editor_open` falsch; `main.player.build.parts.size()` ist 4; `main.player.motion.max_speed` ist 310.0
  3. `_play_a_bit()` → `main.world.visible` wahr; `main.player.input_enabled` wahr
  4. Besuch 2: `_visit()` → `main.editor_open` wahr; `main.editor.set_color(Color.RED)`, `main.editor.confirm()` → `main.player.look.color.is_equal_approx(Color.RED)` wahr; `main.player.build.parts.size()` ist 4
  5. `_play_a_bit()`
  6. Besuch 3: `_visit()` → `main.editor_open` wahr; `main.editor.set_stretch(1.3)`, `main.editor.confirm()` → `var l := CellLook.new()`, `l.set_stretch(1.3)`, `main.player.look.stretch` ist `l.stretch`; `main.player.look.color.is_equal_approx(Color.RED)` wahr; `main.player.build.parts.size()` ist 4; `main.player.motion.max_speed` ist 310.0
  7. `main.stats.editor_visits` ist 3; `SaveGame.read_build(SaveGame.read_file(P)).parts.size()` ist 4
- `test_abbrechen_behaelt_umbau`: `main.start_new(Diet.PFLANZENFRESSER)`, `main.progress.dna = 30`, `main.unlocks.unlock("geissel")`; `_visit()`, Geißel einbauen wie oben, `main.editor.confirm()`; danach `_visit()`, `main.editor.cancel()` → `main.editor_open` falsch; `main.player.build.parts.size()` ist 4; `main.progress.dna` ist 0

Review (17.10.2026): gemergt.
