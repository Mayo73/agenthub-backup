---
id: T-0269
title: FishSpecies – Fischarten der Fischphase
project: zellenphase
priority: 4
---
## Ziel
Meilenstein „Fischphase – Leben im Meer“: Im Meer leben Schwarmfische und Weidefische als Beute und Raubfische als Gefahr. `FishSpecies` hält ihre Werte.

## Dateien
- `scripts/fish_species.gd` – neu
- `tests/test_fish_species.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/fish_species.gd`, genau so:
```gdscript
class_name FishSpecies
extends RefCounted
## Arten der Fischphase. size: Größe wie FishPlayer.size (1 = Spielerfisch am Anfang); speed in m/s;
## bite: Bissschaden (0 = beißt nicht); behavior: "schwarm", "scheu" oder "jaeger"; food: Nahrungswert beim Fressen;
## sight: Sichtweite in Metern.

const DATA := {
	"silberling": {"name": "Silberling", "size": 0.6, "speed": 6.0, "hp": 20.0, "bite": 0.0, "behavior": "schwarm", "color": Color(0.78, 0.84, 0.92), "food": 4, "sight": 12.0},
	"grasfisch": {"name": "Grasfisch", "size": 1.0, "speed": 4.5, "hp": 40.0, "bite": 0.0, "behavior": "scheu", "color": Color(0.42, 0.7, 0.36), "food": 7, "sight": 10.0},
	"zackenbarsch": {"name": "Zackenbarsch", "size": 1.8, "speed": 7.0, "hp": 90.0, "bite": 15.0, "behavior": "jaeger", "color": Color(0.55, 0.32, 0.25), "food": 12, "sight": 18.0},
}


static func ids() -> Array[String]:
	var out: Array[String] = []
	for id: String in DATA:
		out.append(id)
	out.sort()
	return out


static func has(id: String) -> bool:
	return DATA.has(id)


## Werte einer Art; leeres Dictionary bei unbekannter Art.
static func data(id: String) -> Dictionary:
	return DATA.get(id, {})


## Körperradius in Metern (halbe Größe).
static func radius(id: String) -> float:
	return float(data(id).get("size", 1.0)) * 0.5


static func is_predator(id: String) -> bool:
	return float(data(id).get("bite", 0.0)) > 0.0
```

## Tests
Neue Datei `tests/test_fish_species.gd` (`extends "res://tests/base_test.gd"`):
- `test_arten`: `FishSpecies.ids()` ist `["grasfisch", "silberling", "zackenbarsch"]`; `FishSpecies.has("silberling")` wahr; `FishSpecies.has("hai")` falsch
- `test_werte`: `FishSpecies.data("zackenbarsch")["bite"]` ist 15.0; `FishSpecies.data("hai")` ist `{}`
- `test_radius`: `FishSpecies.radius("silberling")` ist 0.3; `FishSpecies.radius("zackenbarsch")` ist 0.9 (Toleranz 0,001)
- `test_raeuber`: `is_predator("zackenbarsch")` wahr; `is_predator("silberling")` falsch; `is_predator("hai")` falsch
- `test_vollstaendig`: jede Art hat die Schlüssel `name`, `size`, `speed`, `hp`, `bite`, `behavior`, `color`, `food`, `sight`
