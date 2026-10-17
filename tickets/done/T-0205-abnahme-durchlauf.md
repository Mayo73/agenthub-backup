---
id: T-0205
title: Abnahmetest – Durchlauf als Pflanzen- und als Fleischfresser bis zum Abschluss
project: zellenphase
priority: 3
---
## Ziel
Abnahmekriterium 2: Je eine Partie als Pflanzen- und als Fleischfresser läuft vom Beginn bis zum Abschlussbildschirm ohne blockierenden Fehler, einmal mit einem Umbau im Editor unterwegs. Der Test füttert die Zelle direkt am Maul. Nur ein neuer Test, keine Änderungen an Skripten.

## Dateien
- `tests/test_abnahme_durchlauf.gd`: neu

## Akzeptanzkriterien
- Nur `tests/test_abnahme_durchlauf.gd` anlegen. Keine Datei unter `scripts/` ändern.
- Kopf: `extends "res://tests/base_test.gd"`, `const P := "user://test_abnahme_durchlauf.json"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `main.save_path = P`, danach `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()` und die Datei `P` löschen, falls vorhanden (`DirAccess.remove_absolute(ProjectSettings.globalize_path(P))`).
- Hilfsfunktionen (nicht `test_` benennen):
```gdscript
## Ein Stück Nahrung direkt ans Maul legen und fressen.
func _bite(kind: String) -> void:
	main.food.items.clear()
	main.food.add_item(kind, main.player.mouth_point())
	main.feed_player()


## Frisst, bis die Bedingung erfüllt ist (höchstens 500 Bissen).
func _eat_until_stage(kind: String, stage: int) -> void:
	var n := 0
	while main.progress.stage < stage and n < 500:
		_bite(kind)
		n += 1


func _eat_until_end(kind: String) -> void:
	var n := 0
	while not PhaseEnd.can_finish(main.progress) and n < 500:
		_bite(kind)
		n += 1


func _visit() -> void:
	main.mate.add_charge()
	main.call_mate()
	main.player.position = main.mate.partner_pos
	main.update_mate()
```

## Tests
- `test_pflanzenfresser`: `main.start_new(Diet.PFLANZENFRESSER)`, `_eat_until_end(Diet.PFLANZE)` → `PhaseEnd.can_finish(main.progress)` wahr; `main.progress.stage` ist 4; `main.player.radius` ist 60.0; `main.stats.food_eaten > 0` wahr; `main.finish_phase()` → `main.finished` wahr; `main.end_screen.visible` wahr; `FileAccess.file_exists(P)` wahr
- `test_fleischfresser`: wie oben mit `Diet.FLEISCHFRESSER` und `Diet.FLEISCH`
- `test_mit_umbau`: `main.start_new(Diet.PFLANZENFRESSER)`, `_eat_until_stage(Diet.PFLANZE, 1)` → `main.progress.stage` ist 1; `_visit()` → `main.editor_open` wahr; `main.editor.set_color(Color.RED)`, `main.editor.confirm()` → `main.editor_open` falsch; danach `_eat_until_end(Diet.PFLANZE)`, `main.finish_phase()` → `main.finished` wahr; `main.stats.editor_visits` ist 1; `main.player.look.color.is_equal_approx(Color.RED)` wahr
- `test_zurueck_ins_menue`: `main.start_new(Diet.FLEISCHFRESSER)`, `_eat_until_end(Diet.FLEISCH)`, `main.finish_phase()`, `main._on_end_to_menu()` → `main.in_menu` wahr; `main.end_screen.visible` falsch; `main.finished` falsch

Review (17.10.2026): gemergt.
