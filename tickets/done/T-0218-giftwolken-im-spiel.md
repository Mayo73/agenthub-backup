---
id: T-0218
title: Giftwolken im Spiel anzeigen
project: zellenphase
priority: 2
after: T-0217
---
## Ziel
Die Hauptszene zeigt die Giftwolken der Spielerzelle mit `PoisonCloudView` an.

## Dateien
- `scripts/main.gd`
- `tests/test_main_gift.gd` – neu

## Akzeptanzkriterien
- In `scripts/main.gd` direkt unter `var electric := ElectricOrgan.new()`:
```gdscript
var poison_view: PoisonCloudView
```
- In `_ready()` direkt nach der Zeile `world.add_child(burst_view)`:
```gdscript

	poison_view = PoisonCloudView.new()
	poison_view.name = "PoisonClouds"
	poison_view.sources = [poison]
	world.add_child(poison_view)
```
- Sonst nichts in `main.gd` ändern.

## Tests
`tests/test_main_gift.gd` mit `extends "res://tests/base_test.gd"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()` und `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()` (wie `tests/test_main_platzen.gd`):
- `test_knoten`: `main.world.get_node("PoisonClouds") is PoisonCloudView` wahr; `main.poison_view.get_parent() == main.world` wahr
- `test_quelle`: `main.poison_view.sources.has(main.poison)` wahr
- `test_wolke_sichtbar`: `main.poison.emit(Vector2(10, 0))` → `main.poison_view.cloud_count()` ist 1

Review (17.10.2026): gemergt.
