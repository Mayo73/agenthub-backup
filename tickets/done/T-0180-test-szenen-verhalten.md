---
id: T-0180
title: Test – Verhalten in den Vorführszenen
project: zellenphase
priority: 3
after: T-0178
---
## Ziel
Ein Test hält Abnahmekriterium 5 fest: In den Szenen „jagd“, „flucht“ und „nahrung“ entscheidet `AiBrain` reproduzierbar für Verfolgung, Flucht und Nahrungssuche. Nur ein neuer Test, keine Änderungen an Skripten.

## Dateien
- `tests/test_szenen_verhalten.gd`: neu

## Akzeptanzkriterien
- Nur `tests/test_szenen_verhalten.gd` anlegen, mit `extends "res://tests/base_test.gd"`. Keine Datei unter `scripts/` ändern.
- Hilfsfunktion in der Testdatei (nicht `test_` benennen): `func _player_info(scene_name: String) -> Dictionary:` gibt `{"position": Vector2.ZERO, "radius": CellProgress.radius_for_stage(int(DemoScenes.data(scene_name)["stage"])), "diet": str(DemoScenes.data(scene_name)["diet"])}` zurück.

## Tests
Jeweils mit `var d := DemoScenes.data(<szene>)`, `var ai: Array = d["ai"][0]`, `var id: String = ai[0]`, `var pos: Vector2 = ai[1]`, `var brain := AiBrain.new()`:
- `test_jagd`: `var wish := brain.decide(pos, SpeciesCatalog.radius_of(id), SpeciesCatalog.data(id)["diet"], [_player_info("jagd")], null)` → `brain.state` ist `AiBrain.JAGEN`; `wish.x < 0.0` wahr (schwimmt auf die Spielerzelle zu)
- `test_flucht`: wie oben mit Szene `"flucht"` → `brain.state` ist `AiBrain.FLIEHEN`; `wish.x > 0.0` wahr (schwimmt von der Spielerzelle weg)
- `test_nahrung`: mit Szene `"nahrung"`, `var food_pos: Vector2 = d["food"][0][1]`; `var wish := brain.decide(pos, SpeciesCatalog.radius_of(id), SpeciesCatalog.data(id)["diet"], [], food_pos)` → `brain.state` ist `AiBrain.SUCHEN`; `wish.is_equal_approx(Vector2(1, 0))` wahr
- `test_ohne_spieler_treiben`: mit Szene `"jagd"`: `brain.decide(pos, SpeciesCatalog.radius_of(id), SpeciesCatalog.data(id)["diet"], [], null)` ist `Vector2.ZERO`; `brain.state` ist `AiBrain.TREIBEN`

Review (17.10.2026): gemergt.
