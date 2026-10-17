---
id: T-0036
title: Gewähltes Auto im Rennen laden
project: drift
priority: 3
after: T-0032, T-0035
---
## Ziel
Das Auto-Node übernimmt Abstimmung und Farbe eines Autos aus dem `CarCatalog`; die Rennszene lädt beim Start das in `GameSettings.car_id` gewählte Auto.

## Dateien
- `scripts/car.gd`
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `car.gd`: neue Variable `var car_id := CarCatalog.DEFAULT_ID` (unter `var smoke`) und neue Funktion:
  ```gdscript
  ## Übernimmt Abstimmung und Farbe eines Autos aus dem CarCatalog. Unbekannte IDs werden ignoriert.
  func apply_car(id: String) -> void:
  	if not CarCatalog.has_car(id):
  		return
  	car_id = id
  	var fresh := CarPhysics.new()
  	fresh.position = physics.position
  	fresh.heading = physics.heading
  	physics = fresh
  	CarCatalog.apply(id, physics)
  	var body := get_node_or_null("Body") as Polygon2D
  	if body:
  		body.color = CarCatalog.color_of(id)
  	var roof := get_node_or_null("Roof") as Polygon2D
  	if roof:
  		roof.color = CarCatalog.color_of(id).darkened(0.3)
  ```
- `main.gd`: in `_ready()` direkt nach `track.load_track(GameSettings.track_id)` die Zeile `car.apply_car(GameSettings.car_id)`. Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_main_wiring.gd` neue Methode `test_gewaehltes_auto_wird_geladen` anhängen:
- `main.car.car_id` ist `GameSettings.car_id`
- `main.car.apply_car("grip")` → `main.car.car_id` ist `"grip"`, `main.car.physics.grip` ist 34.0, `(main.car.get_node("Body") as Polygon2D).color` ist `CarCatalog.color_of("grip")`
- `main.car.apply_car("allround")` → `main.car.physics.grip` ist 30.0 (die Werte des vorigen Autos bleiben nicht hängen)
- `main.car.apply_car("gibtsnicht")` → `main.car.car_id` bleibt `"allround"`

Review (16.10.2026): gemergt.
