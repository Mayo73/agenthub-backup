---
id: T-0233
title: Riesen in der Tiefe im Spiel anzeigen
project: zellenphase
priority: 3
after: T-0232, T-0225
---
## Ziel
Die Hauptszene zeigt die Riesen-Schatten (`DeepGiantView`) direkt über dem Wasserhintergrund und unter allen anderen Dingen der Spielwelt.

## Dateien
- `scripts/main.gd`
- `tests/test_main_riesen.gd` – neu

## Akzeptanzkriterien
- In `scripts/main.gd` direkt unter der Zeile `var backdrop: WaterBackdrop`:
```gdscript
var giant_view: DeepGiantView
```
- In `_ready()` direkt nach der Zeile `world.move_child(backdrop, 0)`:
```gdscript
	giant_view = DeepGiantView.new()
	giant_view.name = "DeepGiants"
	giant_view.camera = camera
	world.add_child(giant_view)
	world.move_child(giant_view, 1)
```
- Sonst nichts in `main.gd` ändern.

## Tests
`tests/test_main_riesen.gd` mit `extends "res://tests/base_test.gd"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()` und `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()` (wie `tests/test_main_gift.gd`):
- `test_knoten`: `main.world.get_node("DeepGiants") is DeepGiantView` wahr; `main.giant_view.get_parent() == main.world` wahr
- `test_reihenfolge`: `main.backdrop.get_index()` ist 0; `main.giant_view.get_index()` ist 1; `main.player.get_index() > main.giant_view.get_index()` wahr
- `test_kamera`: `main.giant_view.camera == main.camera` wahr
