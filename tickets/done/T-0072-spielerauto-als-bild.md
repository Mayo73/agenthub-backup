---
id: T-0072
title: Spielerauto mit Bild statt Polygonen
project: drift
priority: 2
after: T-0071
---
## Ziel
Das Auto des Spielers wird mit seinem Bild aus dem `CarCatalog` gezeichnet statt mit den farbigen Polygonen. Der Schatten bleibt.

## Dateien
- `scripts/car.gd`
- `tests/test_car_sprite.gd`: neu

## Akzeptanzkriterien
- Neue Variable in `car.gd` direkt unter `var squeal_player: AudioStreamPlayer2D`: `var sprite: Sprite2D`
- Neue Funktion direkt vor `apply_car`:
```gdscript
## Zeigt das Bild des Autos. Ohne Bild bleiben die Polygone sichtbar.
func apply_skin(id: String) -> void:
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = "Sprite"
		sprite.scale = Vector2(0.5, 0.5)
		add_child(sprite)
	var path := CarCatalog.sprite_of(id)
	sprite.texture = load(path) as Texture2D if path != "" else null
	for part in ["Body", "Roof", "Windshield", "Headlights", "Headlights2"]:
		var node := get_node_or_null(part) as CanvasItem
		if node:
			node.visible = sprite.texture == null
```
- In `apply_car(id)` als letzte Zeile: `apply_skin(id)`
- In `_ready()` als letzte Zeile: `apply_skin(car_id)`
- Sonst nichts an `car.gd` ändern. Der Knoten `Shadow` bleibt sichtbar.

## Tests
Neue Datei `tests/test_car_sprite.gd` mit `extends "res://tests/base_test.gd"` und `var car: Node2D`. In `setup()`: `car = load("res://scenes/car.tscn").instantiate()` und `(Engine.get_main_loop() as SceneTree).root.add_child(car)`. In `teardown()`: `car.free()`.
- `test_bild_beim_start`: `car.sprite != null`, `car.sprite.texture != null`, `car.get_node("Body").visible` ist falsch, `car.get_node("Shadow").visible` ist wahr.
- `test_bild_wechselt`: nach `car.apply_car("grip")` ist `car.sprite.texture.resource_path` gleich `"res://assets/cars/car_grip.png"`.
- `test_unbekannt_aendert_nichts`: nach `car.apply_car("gibtsnicht")` ist `car.sprite.texture.resource_path` weiterhin `"res://assets/cars/car_allround.png"`.

Review (16.10.2026): gemergt.
