---
id: T-0201
title: Abnahmetest – welche Nahrung jede Ernährungsart aufnimmt
project: zellenphase
priority: 3
---
## Ziel
Abnahmekriterium 3: Für Pflanzen-, Fleisch- und Allesfresser belegt ein Test, welche Nahrung aufgenommen wird. Ungeeignete Nahrung bleibt liegen und erhöht weder DNA noch Wachstum. Nur ein neuer Test, keine Änderungen an Skripten.

## Dateien
- `tests/test_abnahme_nahrung.gd`: neu

## Akzeptanzkriterien
- Nur `tests/test_abnahme_nahrung.gd` anlegen. Keine Datei unter `scripts/` ändern.
- Kopf: `extends "res://tests/base_test.gd"`, `const P := "user://test_abnahme_nahrung.json"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `main.save_path = P`, danach `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()` und die Datei `P` löschen, falls vorhanden (`DirAccess.remove_absolute(ProjectSettings.globalize_path(P))`). So wird nie der echte Spielstand überschrieben.
- Hilfsfunktion (nicht `test_` benennen): `func _feed(kind: String) -> void:` ruft `main.food.items.clear()`, `main.food.add_item(kind, main.player.mouth_point())` und `main.feed_player()` auf.
- Hilfsfunktion `func _allesfresser() -> void:` baut `var b := CellBuild.new()`, `b.add_part("ruessel", Vector2(1, 0))` und ruft `main.player.set_build(b)` auf.

## Tests
- `test_pflanzenfresser_pflanze`: `main.start_new(Diet.PFLANZENFRESSER)`, `_feed(Diet.PFLANZE)` → `main.progress.dna > 0` wahr; `main.progress.growth > 0` wahr; `main.food.items.size()` ist 0
- `test_pflanzenfresser_fleisch`: `main.start_new(Diet.PFLANZENFRESSER)`, `_feed(Diet.FLEISCH)` → `main.progress.dna` ist 0; `main.progress.growth` ist 0; `main.food.items.size()` ist 1
- `test_fleischfresser_fleisch`: `main.start_new(Diet.FLEISCHFRESSER)`, `_feed(Diet.FLEISCH)` → `main.progress.dna > 0` wahr; `main.food.items.size()` ist 0
- `test_fleischfresser_pflanze`: `main.start_new(Diet.FLEISCHFRESSER)`, `_feed(Diet.PFLANZE)` → `main.progress.dna` ist 0; `main.progress.growth` ist 0; `main.food.items.size()` ist 1
- `test_allesfresser`: `main.start_new(Diet.PFLANZENFRESSER)`, `_allesfresser()` → `main.player.diet` ist `Diet.ALLESFRESSER`; `_feed(Diet.PFLANZE)` → `var nach_pflanze: int = main.progress.dna`, `nach_pflanze > 0` wahr; `_feed(Diet.FLEISCH)` → `main.progress.dna > nach_pflanze` wahr

Review (17.10.2026): gemergt.
