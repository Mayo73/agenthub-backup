---
id: T-0034
title: Autokatalog mit 3 Autos (CarCatalog)
project: drift
priority: 3
---
## Ziel
Drei Autos mit eigenem Fahrverhalten und eigener Farbe: „Allrounder“ (ausgewogen, die bisherigen Werte), „Grip-Coupé“ (griffig) und „Drift-Kombi“ (driftfreudig). Eine Klasse `CarCatalog` hält ihre Daten und überträgt die Abstimmung auf eine `CarPhysics`.

## Dateien
- `scripts/car_catalog.gd`: neu, beginnt mit `class_name CarCatalog` und `extends RefCounted`
- `tests/test_car_catalog.gd`: neu

## Akzeptanzkriterien
- `const DEFAULT_ID := "allround"`
- Konstante mit genau diesen Daten:
  ```gdscript
  const CARS := {
  	"allround": {
  		"name": "Allrounder",
  		"color": Color(0.86, 0.2, 0.18),
  		"tuning": {},
  	},
  	"grip": {
  		"name": "Grip-Coupé",
  		"color": Color(0.2, 0.45, 0.9),
  		"tuning": {"grip": 34.0, "slide_grip": 2.2, "traction_limit": 1700.0, "max_speed": 740.0, "power_oversteer": 0.8},
  	},
  	"drifter": {
  		"name": "Drift-Kombi",
  		"color": Color(0.95, 0.75, 0.15),
  		"tuning": {"traction_limit": 1150.0, "slide_grip": 1.2, "handbrake_grip": 0.45, "power_oversteer": 1.5, "drift_steer_bonus": 1.6, "max_speed": 775.0},
  	},
  }
  ```
- `static func ids() -> Array[String]`: alle Schlüssel von `CARS` in dieser Reihenfolge
- `static func has_car(id: String) -> bool`
- `static func name_of(id: String) -> String`: `""`, wenn unbekannt
- `static func color_of(id: String) -> Color`: `Color.WHITE`, wenn unbekannt
- `static func apply(id: String, physics: CarPhysics) -> void`: tut nichts, wenn unbekannt; sonst für jeden Schlüssel `key` in `CARS[id]["tuning"]`: `physics.set(key, CARS[id]["tuning"][key])`
- `scripts/car_physics.gd` **nicht** ändern.

## Tests
Neue Datei `tests/test_car_catalog.gd` mit `extends "res://tests/base_test.gd"`:
- `test_drei_autos`: `CarCatalog.ids()` hat Größe 3 und enthält `"allround"`, `"grip"`, `"drifter"`; `CarCatalog.has_car(CarCatalog.DEFAULT_ID)` ist wahr
- `test_namen_und_farben`: `name_of("grip")` ist `"Grip-Coupé"`, `name_of("gibtsnicht")` ist `""`, `color_of("drifter")` ist `Color(0.95, 0.75, 0.15)`, `color_of("gibtsnicht")` ist `Color.WHITE`
- `test_allround_aendert_nichts`: `var p := CarPhysics.new()`, `CarCatalog.apply("allround", p)` → `p.grip` ist 30.0 und `p.traction_limit` ist 1400.0
- `test_grip_ist_griffiger`: `var p := CarPhysics.new()`, `CarCatalog.apply("grip", p)` → `p.grip` ist 34.0, `p.traction_limit` ist 1700.0, `p.max_speed` ist 740.0
- `test_drifter_rutscht_eher`: `var p := CarPhysics.new()`, `CarCatalog.apply("drifter", p)` → `p.traction_limit` ist 1150.0, `p.handbrake_grip` ist 0.45, `p.drift_steer_bonus` ist 1.6

Review (16.10.2026): gemergt.
