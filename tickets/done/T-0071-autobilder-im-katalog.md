---
id: T-0071
title: Autobilder und Gegner-Autos im CarCatalog
project: drift
priority: 2
after: A-0002, A-0003, A-0004
---
## Ziel
Der `CarCatalog` kennt zu jedem Auto das Bild (von oben, aus den Medien-Aufträgen A-0002 bis A-0004) und kann für die KI-Gegner eine Liste anderer Autos liefern.

## Dateien
- `scripts/car_catalog.gd`
- `tests/test_car_catalog.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- In `CARS` bekommt jedes Auto einen Eintrag `"sprite"`: `"allround"` → `"res://assets/cars/car_allround.png"`, `"grip"` → `"res://assets/cars/car_grip.png"`, `"drifter"` → `"res://assets/cars/car_drifter.png"`.
- Neue Funktion direkt nach `color_of`:
```gdscript
## Pfad zum Bild des Autos (von oben, Front nach rechts). Leer bei unbekannter ID.
static func sprite_of(id: String) -> String:
	if not CARS.has(id):
		return ""
	return CARS[id]["sprite"]
```
- Neue Funktion am Ende der Datei:
```gdscript
## Autos für die KI-Gegner: beginnt mit dem Auto nach dem des Spielers (Reihenfolge von ids())
## und wiederholt die Liste, bis count Einträge da sind.
static func opponents(player_id: String, count: int) -> Array[String]:
	var all := ids()
	var start := all.find(player_id) + 1
	var result: Array[String] = []
	for i in count:
		result.append(all[(start + i) % all.size()])
	return result
```

## Tests
In `tests/test_car_catalog.gd` anhängen:
- `test_bilder`: für jede `id` in `CarCatalog.ids()` ist `ResourceLoader.exists(CarCatalog.sprite_of(id))` wahr; `CarCatalog.sprite_of("gibtsnicht")` ist `""`; `CarCatalog.sprite_of("grip")` ist `"res://assets/cars/car_grip.png"`.
- `test_gegner`: `CarCatalog.opponents("allround", 3)` ist `["grip", "drifter", "allround"]`; `CarCatalog.opponents("drifter", 2)` ist `["allround", "grip"]`; `CarCatalog.opponents("gibtsnicht", 1)` ist `["allround"]`. Mit `check_eq` gegen typisierte Arrays vergleichen, z. B. `var expected: Array[String] = ["grip", "drifter", "allround"]`.

Review (16.10.2026): gemergt, nachgebessert: Einrückung des CARS-Blocks korrigiert.
