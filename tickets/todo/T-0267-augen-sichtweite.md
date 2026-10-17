---
id: T-0267
title: Bessere Augen lichten den Nebel unter Wasser
project: zellenphase
priority: 4
after: T-0266
---
## Ziel
Die Augen sollen spielerisch wirken: Je höher ihre Stufe, desto weiter sieht man im trüben Wasser. Der Nebel der Umgebung wird mit jeder Stufe dünner.

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- In `scripts/fish_main.gd` neue Funktionen (direkt vor `func _physics_process`):
```gdscript
## Nebeldichte zur Sichtweite: 0,025 bei 25 m (Anfang), dünner bei größerer Sicht.
static func fog_density_for(sight: float) -> float:
	return 0.025 * 25.0 / maxf(sight, 1.0)


## Stellt den Nebel passend zu den Augen des Fischs ein.
func apply_sight() -> void:
	water.environment.fog_density = fog_density_for(FishAbilities.sight(player.build))
```
- In `_ready()` direkt nach der Zeile `FishStart.clear()` die Zeile `apply_sight()`.
- In `_on_upgraded(slot)` als letzte Zeile `apply_sight()`.
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen:
- `test_nebel_formel`: `FishMain.fog_density_for(25.0)` ist 0.025; `FishMain.fog_density_for(50.0)` ist 0.0125; `FishMain.fog_density_for(0.0)` ist 0.625 (Toleranz 0,0001)
- `test_nebel_anfang`: `fish.water.environment.fog_density` ist 0.025 (Toleranz 0,0001)
- `test_augen_lichten_nebel`: `fish.progress.dna = 50`; `fish.toggle_evolve()`; `fish.evolve.try_upgrade("augen")` → `fish.water.environment.fog_density < 0.025` wahr
