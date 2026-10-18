---
id: T-0295
title: Fischszene wird in der Tiefe dunkler
project: zellenphase
priority: 4
after: T-0293, T-0294
---
## Ziel
Die Fischszene nutzt `FishWorld.water_color_at` und `FishWorld.ambient_energy_at` (T-0294): Hintergrund, Nebelfarbe und Umgebungslicht folgen der Tiefe der Kamera.

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- Neue Funktion am Ende von `scripts/fish_main.gd`:
```gdscript
## Wasserfarbe, Nebelfarbe und Umgebungslicht passend zur Tiefe der Kamera.
func apply_depth_light(depth: float) -> void:
	var env := water.environment
	env.background_color = FishWorld.water_color_at(depth)
	env.fog_light_color = env.background_color
	env.ambient_light_energy = FishWorld.ambient_energy_at(depth)
```
- In `_process(delta)` als letzte Zeile: `apply_depth_light(FishWorld.depth_of(camera.position))`.
- Sonst nichts ändern (die Nebeldichte bleibt Sache von `apply_sight()`).

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen:
- `test_tiefenlicht`: `fish.apply_depth_light(0.0)` → `fish.water.environment.background_color` ist `FishWorld.WATER_COLOR`; `fish.apply_depth_light(FishWorld.DEPTH)` → `background_color` ist `FishWorld.DEEP_COLOR`, `fog_light_color` ist `FishWorld.DEEP_COLOR`, `ambient_light_energy` ist 0.35
- `test_tiefenlicht_nebel_bleibt`: `var dichte: float = fish.water.environment.fog_density`; `fish.apply_depth_light(40.0)` → `fog_density` ist `dichte`
- `test_tiefenlicht_in_process`: `fish._process(0.1)` → `fish.water.environment.ambient_light_energy` ist `FishWorld.ambient_energy_at(FishWorld.depth_of(fish.camera.position))`

Review (18.10.2026): gemergt.
