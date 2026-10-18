---
id: T-0294
title: Wasserfarbe und Licht hängen von der Tiefe ab
project: zellenphase
priority: 4
---
## Ziel
Meilenstein „Fischphase – Optik, Klang, Speichern und Abnahme“: Unter Wasser wird es mit der Tiefe dunkler und blauer. `FishWorld` bekommt zwei Funktionen, die Wasserfarbe und Umgebungslicht für eine Tiefe liefern. Eingebaut wird das in T-0295.

## Dateien
- `scripts/fish_world.gd`
- `tests/test_fish_world.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/fish_world.gd`: unter `const SURFACE_COLOR := …` die Konstante
  `const DEEP_COLOR := Color(0.01, 0.06, 0.13)` mit Kommentar `## Wasserfarbe am Meeresboden.`
- Neue Funktionen am Ende:
```gdscript
## Anteil der Tiefe (0 an der Oberfläche, 1 am Boden).
static func depth_ratio(depth: float) -> float:
	return clampf(depth / DEPTH, 0.0, 1.0)


## Wasserfarbe in dieser Tiefe: oben WATER_COLOR, am Boden DEEP_COLOR.
static func water_color_at(depth: float) -> Color:
	return WATER_COLOR.lerp(DEEP_COLOR, depth_ratio(depth))


## Stärke des Umgebungslichts in dieser Tiefe: 0,9 an der Oberfläche, 0,35 am Boden.
static func ambient_energy_at(depth: float) -> float:
	return lerpf(0.9, 0.35, depth_ratio(depth))
```
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_world.gd` anhängen:
- `test_tiefenanteil`: `depth_ratio(0.0)` ist 0.0; `depth_ratio(30.0)` ist 0.5; `depth_ratio(-5.0)` ist 0.0; `depth_ratio(90.0)` ist 1.0
- `test_wasserfarbe`: `water_color_at(0.0)` ist `FishWorld.WATER_COLOR`; `water_color_at(FishWorld.DEPTH)` ist `FishWorld.DEEP_COLOR`; `water_color_at(40.0).get_luminance() < water_color_at(10.0).get_luminance()` wahr
- `test_licht`: `ambient_energy_at(0.0)` ist 0.9; `ambient_energy_at(60.0)` ist 0.35; `ambient_energy_at(30.0)` ist 0.625

Review (18.10.2026): gemergt, nachgebessert: Kommentar zu DEEP_COLOR in eigene Zeile.
